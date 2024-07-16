defmodule Tft_tracker.SummonerWorker do
  @moduledoc """
  This worker is the general manager of the summoner and is in charge to start other workers under the summoner supervisor.
  """

  require Logger
  use GenServer

  alias Tft_tracker.HttpClient
  alias Tft_tracker.Embeds
  alias Tft_tracker.Structs.LiveGameData

  def start_link(init_args) do
    name = String.to_atom("#{Keyword.fetch!(init_args, :summoner_puuid)}_worker")
    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(init_args) do
    Logger.info("Initializing Worker for Summoner #{init_args[:summoner_puuid]}... ")

    state = %{
      supervisor_pid: init_args[:supervisor_pid],
      summoner_puuid: init_args[:summoner_puuid],
      live_game_data: %LiveGameData{}
    }

    GenServer.cast(self(), :initialize_live_worker)
    GenServer.cast(self(), :initialize_gametag_worker)

    {:ok, state}
  end

  @impl true
  def handle_cast(:initialize_live_worker, state) do
    poller_child_specs = %{
      id: "summoner_poller_live_#{state.summoner_puuid}",
      start: {Tft_tracker.SummonerLivePollerWorker, :start_link, [[worker_pid: self(), summoner_puuid: state.summoner_puuid]]}
    }
    case DynamicSupervisor.start_child(state.supervisor_pid, poller_child_specs) do
      {:ok, _child} ->
        Logger.debug("Started live poller worker for summoner: #{state.summoner_puuid}")
      {:error, reason} ->
        Logger.error("Failed to start live poller worker for summoner: #{state.summoner_puuid} with reason: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:initialize_gametag_worker, state) do
    gametag_child_specs = %{
      id: "summoner_gametag_#{state.summoner_puuid}",
      start: {Tft_tracker.SummonerGametagWorker, :start_link, [[worker_pid: self(), summoner_puuid: state.summoner_puuid]]}
    }
    case DynamicSupervisor.start_child(state.supervisor_pid, gametag_child_specs) do
      {:ok, _child} ->
        Logger.debug("Started GameTag worker for summoner: #{state.summoner_puuid}")
      {:error, reason} ->
        Logger.error("Failed to start GameTag worker for summoner: #{state.summoner_puuid} with reason: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:live_response, new_game_data}, state) do
    # The most important to check here is if we have a new game_id or not
    # IO.inspect(new_game_data)
    # IO.inspect(state)
    if state.live_game_data.game_id != new_game_data.game_id do
      Logger.debug("Detected new game ID for summoner #{state.summoner_puuid}")
      # Player is now in a game, alert player tracked guilds
      if new_game_data.in_game do
        if state.live_game_data.in_game do
          Logger.debug("Summoner is no longer in this game: #{state.live_game_data.game_id}")

          poller_child_specs = %{
            id: "poller_results_#{state.summoner_puuid}_#{state.live_game_data.game_id}",
            start: {Tft_tracker.SummonerResultWorker, :start_link, [[summoner_puuid: state[:summoner_puuid], game_id: state.live_game_data.game_id, icon_id: state.live_game_data.icon_id]]},
            restart: :temporary
          }
          DynamicSupervisor.start_child(state.supervisor_pid, poller_child_specs)
        end
        Logger.debug("Summoner is now in a game: #{new_game_data.game_id}")
        guild_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_summoner_guilds, state[:summoner_puuid]})
        channel_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_guild_ids_channels, guild_ids})
        game_tag = HttpClient.get_gametag_from_puuid(state[:summoner_puuid])
        embed = Embeds.InGame.create_embed(new_game_data.queue_id, game_tag.game_name, new_game_data.icon_id)
        Tft_tracker.AlertsDispatcher.dispatch_embed(embed, channel_ids)
      else
        Logger.debug("Summoner is no longer in this game: #{state.live_game_data.game_id}")

        poller_child_specs = %{
          id: "poller_results_#{state.summoner_puuid}_#{state.live_game_data.game_id}",
          start: {Tft_tracker.SummonerResultWorker, :start_link, [[summoner_puuid: state[:summoner_puuid], game_id: state.live_game_data.game_id, icon_id: state.live_game_data.icon_id]]},
          restart: :temporary
        }
        DynamicSupervisor.start_child(state.supervisor_pid, poller_child_specs)
      end

      new_state = %{state | live_game_data: new_game_data}
      {:noreply, new_state}
    else
      Logger.debug("No live game data changes for #{state.summoner_puuid}")
      {:noreply, state}
    end
  end
end
