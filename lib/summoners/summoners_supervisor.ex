defmodule Tft_tracker.SummonersSupervisor do
  @moduledoc """
  This supervisor is in charge to supervise every unique summoner supervisor.
  """
  require Logger
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.notice("Initializing Summoners Dynamic Supervisor... ")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
