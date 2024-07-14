defmodule Tft_tracker.Main do
  use Application

  # Entry Point of the program, defined by application/1 in mix.exs
  def start(_type, _args) do
    children = [
      Tft_tracker.RedisWorker,
      Nosedrum.Storage.Dispatcher,
      Tft_tracker.CommandHandler,
      Tft_tracker.SummonersSupervisor,
      Tft_tracker.SummonersManager
    ]

    options = [strategy: :rest_for_one, name: Tft_tracker.Supervisor]
    Supervisor.start_link(children, options)
  end
end
