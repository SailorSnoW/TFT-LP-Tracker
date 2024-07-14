defmodule Tft_tracker.SummonerResultWorker do
  alias Tft_tracker.Embeds.ResultGame
  alias Tft_tracker.AlertsDispatcher
  alias Tft_tracker.Structs.GameResults
  alias Tft_tracker.HttpClient
  require Logger
  use GenServer

  @poll_interval 30000 # 30 seconds

  def start_link(init_args) do
    name = String.to_atom("#{Keyword.fetch!(init_args, :summoner_puuid)}-#{init_args[:game_id]}_result_worker")
    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(init_args) do
    Logger.info("Initializing Result Worker for Summoner #{init_args[:summoner_puuid]}... ")

    state = %{
      summoner_puuid: init_args[:summoner_puuid],
      platform: init_args[:platform],
      game_id: init_args[:game_id],
      icon_id: init_args[:icon_id]
    }

    first_schedule_poll()

    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    case fetch_game_results(state[:game_id], state[:platform], state[:summoner_puuid], state[:icon_id]) do
      :not_found ->
        schedule_poll()
        {:noreply, state}
      _ ->
        Logger.debug("Game results successfuly retrieved and alerts dispatched, shutting down.")
        {:stop, :normal, state}
    end
  end

  defp schedule_poll() do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp first_schedule_poll() do
    Process.send_after(self(), :poll, 1000)
  end

  @spec fetch_game_results(String.t(), String.t(), String.t(), String.t()) :: :not_found | nil
  defp fetch_game_results(game_id, platform, puuid, icon_id) do
    Logger.debug("Fetching results for game #{game_id}... ")
    case HttpClient.get_match_result(game_id, String.to_atom(platform)) do
      :not_found ->
        Logger.debug("Game #{game_id} results still not available, will retry.")
        :not_found
      body ->
        Logger.debug("Successfuly got game #{game_id} results!")
        data = GameResults.parse_from_body_response(body, puuid)

        guild_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_summoner_guilds, puuid})
        channel_ids = GenServer.call(Tft_tracker.RedisWorker, {:get_guild_ids_channels, guild_ids})
        game_name = HttpClient.get_game_name_from_puuid(puuid)
        AlertsDispatcher.dispatch_embed(
          ResultGame.create_embed(
            String.to_atom(platform),
            game_name,
            icon_id,
            data
          ),
          channel_ids
        )
        nil
    end
  end
end
