defmodule Tft_tracker.SummonersManager do
  require Logger
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.notice("Initializing Summoners Manager... ")

    children = Tft_tracker.SummonersDbFetcher.fetch_db_summoners()
    Enum.each(children, fn children_info ->
      start_summoner(children_info.puuid, children_info.child_spec)
    end)

    {:ok, %{}}
  end

  @impl true
  def handle_call({:start_summoner, puuid}, _from, state) do
    specs = %{
      id: "summoner_supervisor_#{puuid}",
      start: {Tft_tracker.SummonerSupervisor, :start_link, [[summoner_puuid: puuid]]}
    }
    result = start_summoner(puuid, specs)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:register_summoner, puuid, platform, guild_id}, _from, state) do
    result = register_summoner(puuid, platform, guild_id)
    {:reply, result, state}
  end

  @spec start_summoner(String.t(), Supervisor.child_spec()) :: :ok | {:error, String.t()}
  defp start_summoner(puuid, specs) do
    case DynamicSupervisor.start_child(Tft_tracker.SummonersSupervisor, specs) do
      {:ok, child} ->
        Logger.info("Started #{specs.id} successfully")
        start_summoner_worker(child, %{
          id: "summoner_worker_#{puuid}",
          start: {Tft_tracker.SummonerWorker, :start_link, [[summoner_puuid: puuid, supervisor_pid: child]]}
        })

      {:error, {:already_started, _pid}} ->
        Logger.notice("Supervisor for summoner #{puuid} is already started. Ignoring error.")
        :ok

      {:error, reason} ->
        Logger.error("Failed to start #{specs.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec start_summoner_worker(pid(), Supervisor.child_spec()) :: :ok | {:error, String.t()}
  defp start_summoner_worker(supervisor_pid, specs) do
    case DynamicSupervisor.start_child(supervisor_pid, specs) do
      {:ok, _child} ->
        Logger.info("Started #{specs.id} successfully")
        :ok
      {:error, reason} ->
        Logger.error("Failed to start #{specs.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp register_summoner(puuid, platform, guild_id) do
    # DB writes
    Logger.debug("Registering new summoner infos for #{puuid} on #{guild_id} to DB... ")
    GenServer.call(Tft_tracker.RedisWorker, {:register_summoner, puuid, platform, guild_id})

    Logger.debug("Starting summoner workers for #{puuid}... ")
    # Start summoner work
    specs = %{
      id: "summoner_supervisor_#{puuid}",
      start: {Tft_tracker.SummonerSupervisor, :start_link, [[summoner_puuid: puuid]]}
    }
    start_summoner(puuid, specs)
  end

end
