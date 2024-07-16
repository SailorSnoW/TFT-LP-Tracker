defmodule Tft_tracker.SummonerGametagWorker do
  @moduledoc """
  This module serve as a worker to fetch and cache a potential game name change at a regular interval.
  """
  alias Tft_tracker.HttpClient
  require Logger
  use GenServer

  @fetch_interval 43200000 # 12 hours

  def start_link(init_args) do
    name = String.to_atom("#{Keyword.fetch!(init_args, :summoner_puuid)}_gametag_worker")
    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(init_args) do
    Logger.notice("Initializing GameTag Worker for Summoner #{init_args[:summoner_puuid]}... ")

    state = %{
      summoner_puuid: init_args[:summoner_puuid],
    }

    schedule_fetch()

    {:ok, state}
  end

  @impl true
  def handle_info(:fetch, state) do
    Logger.notice("Starting a new GameTag fetching for #{state[:summoner_puuid]}.")
    fetch_gametag(state[:summoner_puuid])
    schedule_fetch()
    {:noreply, state}
  end

  defp schedule_fetch() do
    Process.send_after(self(), :fetch, @fetch_interval)
  end

  defp fetch_gametag(puuid) do
    case HttpClient.get_gametag_from_puuid(puuid) do
      :not_found ->
        Logger.critical(
          "GameTag for account #{puuid} wasn't found!\n
          This could mean that the account doesn't exist anymore and should be removed !"
        )
      game_tag ->
        Logger.debug("Successfuly got new GameTag #{game_tag.game_name}##{game_tag.tag_line} for #{puuid}")
        # Write new gametag to DB
        GenServer.call(Tft_tracker.RedisWorker, {:set_summoner_nametag, puuid, game_tag.game_name, game_tag.tag_line})
    end
  end

end
