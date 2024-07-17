defmodule Tft_tracker.SummonerLivePollerWorker do
  @moduledoc """
  This worker keep monitoring on the Riot Spectator API the state of the player.
  If the player is detected in a game, game data are parsed then transfered to the general summoner worker.
  """

  alias Tft_tracker.Types.Queues
  alias Tft_tracker.Structs.LiveGameData
  require Logger
  use GenServer

  @poll_interval 30000 # 30 secondes

  def start_link(init_args) do
    name = String.to_atom("#{Keyword.fetch!(init_args, :summoner_puuid)}_live_poller")
    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(init_args) do
    Logger.info("Initializing live poller worker for Summoner #{init_args[:summoner_puuid]}... ")
    state = %{
      worker_pid: init_args[:worker_pid],
      summoner_puuid: init_args[:summoner_puuid],
      icon_id: "0"
    }

    first_schedule_poll()

    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    case poll_live_api(state) do
      :not_in_game ->
        Logger.debug("Sending not in game signal to supervisor #{state[:summoner_puuid]}")
        send(state.worker_pid, {:live_response, %LiveGameData{}})
      body ->
        data = parse_live_response(body, state[:summoner_puuid])
        # Ensure we deal with a compatible queue mode
        if Queues.is_ranked_queue?(data.queue_id) do
          Logger.debug("Sending new live game data to supervisor #{state[:summoner_puuid]}")
          send(state.worker_pid, {:live_response, data})
        end
    end

    schedule_poll()

    {:noreply, state}
  end

  defp schedule_poll() do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp first_schedule_poll() do
    Process.send_after(self(), :poll, 1000)
  end

  @spec poll_live_api(any()) :: map() | :not_in_game
  defp poll_live_api(state) do
    platform = GenServer.call(Tft_tracker.RedisWorker, {:get_summoner_platform, state.summoner_puuid})
    Tft_tracker.HttpClient.get_current_game_infos(state[:summoner_puuid], String.to_atom(platform))
  end

  @spec parse_live_response(map(), String.t()) :: LiveGameData.t()
  # Parse the full response body of the Riot TFT-Spectator API into the summoner worker cached data.
  defp parse_live_response(body, puuid) do
    %LiveGameData{
      game_id: "#{body["platformId"]}_#{body["gameId"]}",
      in_game: true,
      icon_id: get_profile_icon_id(body, puuid),
      queue_id: body["gameQueueConfigId"]
    }
  end

  defp get_profile_icon_id(game_data, puuid) do
    game_data["participants"]
    |> Enum.find(fn participant -> participant["puuid"] == puuid end)
    |> case do
      nil -> "0"
      participant -> participant["profileIconId"]
    end
  end
end
