defmodule Tft_tracker.SummonersDbFetcher do
  require Logger

  @doc """
  Retrieve all tracker summoners in DB and create childrens ready to be started and supervised.
  """
  @spec fetch_db_summoners() :: list()
  def fetch_db_summoners() do
    Logger.info("Retrieving all tracked summoners... ")
    tracked_summoners = GenServer.call(Tft_tracker.RedisWorker, {:get_tracked_summoners})
    Logger.info("Got a total of #{length(tracked_summoners)} tracked summoners... ")

    Enum.map(tracked_summoners, fn summoner ->
      %{
        puuid: summoner,
        child_spec: %{
          id: "summoner_supervisor_#{summoner}",
          start: {Tft_tracker.SummonerSupervisor, :start_link, [[summoner_puuid: summoner]]}
        },
      }
    end)
  end
end
