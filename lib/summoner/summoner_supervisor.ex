defmodule Tft_tracker.SummonerSupervisor do
  require Logger;
  use DynamicSupervisor

  def start_link(init_args) do
    name = String.to_atom("#{Keyword.fetch!(init_args, :summoner_puuid)}_supervisor")
    DynamicSupervisor.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(init_args) do
    Logger.info("Initializing supervisor for Summoner #{init_args[:summoner_puuid]}... ")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
