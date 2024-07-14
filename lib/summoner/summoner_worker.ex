defmodule Tft_tracker.SummonerWorker do
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
      platform: nil,
      live_game_data: %LiveGameData{}
    }

    GenServer.cast(self(), :initialize_poller)

    {:ok, state}
  end

  @impl true
  def handle_cast(:initialize_poller, state) do
    Logger.debug("Retrieving cached summoner platform... ")
    platform = GenServer.call(Tft_tracker.RedisWorker, {:get_summoner_platform, state.summoner_puuid})

    new_state = %{state | platform: platform}

    poller_child_specs = %{
      id: "summoner_poller_live_#{state.summoner_puuid}",
      start: {Tft_tracker.SummonerLivePollerWorker, :start_link, [[worker_pid: self(), summoner_puuid: state.summoner_puuid, platform: platform]]}
    }
    case DynamicSupervisor.start_child(state.supervisor_pid, poller_child_specs) do
      {:ok, _child} ->
        Logger.info("Started live poller worker for summoner: #{state.summoner_puuid}")
      {:error, reason} ->
        Logger.error("Failed to start live poller worker for summoner: #{state.summoner_puuid} with reason: #{inspect(reason)}")
    end

    {:noreply, new_state}
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
            start: {Tft_tracker.SummonerResultWorker, :start_link, [[summoner_puuid: state[:summoner_puuid], platform: state[:platform], game_id: state.live_game_data.game_id, icon_id: state.live_game_data.icon_id]]},
            restart: :temporary
          }
          DynamicSupervisor.start_child(state.supervisor_pid, poller_child_specs)
        end
        Logger.debug("Summoner is now in a game: #{new_game_data.game_id}")
        guild_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_summoner_guilds, state[:summoner_puuid]})
        channel_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_guild_ids_channels, guild_ids})
        game_name = HttpClient.get_game_name_from_puuid(state[:summoner_puuid])
        embed = Embeds.InGame.create_embed(new_game_data.queue_id, game_name, new_game_data.icon_id)
        Tft_tracker.AlertsDispatcher.dispatch_embed(embed, channel_ids)
      else
        Logger.debug("Summoner is no longer in this game: #{state.live_game_data.game_id}")

        poller_child_specs = %{
          id: "poller_results_#{state.summoner_puuid}_#{state.live_game_data.game_id}",
          start: {Tft_tracker.SummonerResultWorker, :start_link, [[summoner_puuid: state[:summoner_puuid], platform: state[:platform], game_id: state.live_game_data.game_id, icon_id: state.live_game_data.icon_id]]},
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
