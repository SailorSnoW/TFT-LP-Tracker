defmodule Tft_tracker.RedisWorker do
  @moduledoc """
  Lower level module that is reserved to interact with the Redis backend.
  This serve as a bridge between the Redis database and the higher level module of this application.
  """
  alias Tft_tracker.Types.Platforms
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  def init(_init_arg) do
    Logger.notice("Initializing Redis Worker and Redix... ")
    host = Application.get_env(:tft_tracker, :redis_host)
    port = Application.get_env(:tft_tracker, :redis_port)

    {:ok, redix_pid} = Redix.start_link(host: host, port: String.to_integer(port) , name: :redix)
    {:ok, %{redix_pid: redix_pid}}
  end

  @impl true
  def handle_call({:register_summoner, puuid, platform, guild_id, game_name, tag_line, summoner_id}, _from, state) do
    result = register_summoner(state.redix_pid, puuid, platform, guild_id, game_name, tag_line, summoner_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:unregister_summoner, puuid, platform, guild_id}, _from, state) do
    result = unregister_summoner(state.redix_pid, puuid, platform, guild_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_tracked_summoners}, _from, state) do
    result = get_tracked_summoners(state.redix_pid)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_summoner_platform, puuid}, _from, state) do
    result = get_summoner_platform(state.redix_pid, puuid)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:set_guild_channel, guild_id, channel_id}, _from, state) do
    result = set_guild_channel(state.redix_pid, guild_id, channel_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_guild_channel, guild_id}, _from, state) do
    result = get_guild_channel(state.redix_pid, guild_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_guild_ids_channels, guild_ids}, _from, state) do
    result = get_guild_ids_channels(state.redix_pid, guild_ids)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_summoner_guilds, puuid}, _from, state) do
    result = get_summoner_guilds(state.redix_pid, puuid)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:set_summoner_nametag, puuid, game_name, tag_line}, _from, state) do
    result = set_summoner_nametag(state.redix_pid, puuid, game_name, tag_line)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_summoner_nametag, puuid}, _from, state) do
    result = get_summoner_nametag(state.redix_pid, puuid)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:set_summoner_icon_id, puuid, icon_id}, _from, state) do
    result = set_summoner_icon_id(state.redix_pid, puuid, icon_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_summoner_icon_id, puuid}, _from, state) do
    result = get_summoner_icon_id(state.redix_pid, puuid)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:set_summoner_id, puuid, summoner_id}, _from, state) do
    result = set_summoner_id(state.redix_pid, puuid, summoner_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_summoner_id, puuid}, _from, state) do
    result = get_summoner_id(state.redix_pid, puuid)
    {:reply, result, state}
  end

  @spec register_summoner(pid(), String.t(), Platforms.t(), String.t(), String.t(), String.t(), String.t()) :: :ok | :error
  defp register_summoner(redix_pid, puuid, platform, guild_id, game_name, tag_line, summoner_id) do
    Logger.debug("Registering summoner #{puuid} with associated guild_id #{guild_id} and platform #{platform} ...")

    case Redix.pipeline(redix_pid, [
      ["SADD", "summoner:#{puuid}:guilds", "#{guild_id}"],
      ["SET", "summoner:#{puuid}:platform", "#{platform}"],
      ["SET", "summoner:#{puuid}:name", game_name],
      ["SET", "summoner:#{puuid}:tag", tag_line],
      ["SET", "summoner:#{puuid}:id", summoner_id],
      ["SADD", "summoners", "#{puuid}"],
      ]) do
      {:ok, _} ->
        Logger.debug("Successfuly added guild_id #{guild_id} for summoner #{puuid} with platform #{platform}")
        :ok
      {:error, e} ->
        Logger.error(e)
        :error
    end
  end

  @spec unregister_summoner(pid(), String.t(), Platforms.t(), String.t()) :: :ok | :error
  defp unregister_summoner(redix_pid, puuid, platform, guild_id) do
    Logger.debug("Unregistering summoner #{puuid} with associated guild_id #{guild_id} and platform #{platform} ...")

    case Redix.pipeline(redix_pid, [
      ["SREM", "summoner:#{puuid}:guilds", "#{guild_id}"],
      ]) do
      {:ok, _} ->
        Logger.info("Successfuly removed guild_id #{guild_id} for summoner #{puuid}")
        if Redix.command(redix_pid, ["SMEMBERS", "summoner:#{puuid}:guilds"]) == {:ok, []} do
          Logger.info("No more tracking needed for #{puuid}, removing it entierly...")
          Redix.pipeline!(redix_pid, [
            ["SREM", "summoners", "#{puuid}"],
            ["DEL", "summoner:#{puuid}:platform"],
            ["DEL", "summoner:#{puuid}:name"],
            ["DEL", "summoner:#{puuid}:tag"],
          ])
          Logger.info("Successfuly removed #{puuid} and related stuff from tracking database!")
        end
        :ok
      {:error, e} ->
        Logger.error(e)
        :error
    end
  end

  @spec get_tracked_summoners(pid()) :: list()
  defp get_tracked_summoners(redix_pid) do
    Logger.debug("Fetching all stored tracked summoners...")
    Redix.command!(redix_pid, ["SMEMBERS", "summoners"])
  end

  @spec get_summoner_platform(pid(), String.t()) :: Redix.Protocol.redis_value()
  defp get_summoner_platform(redix_pid, puuid) do
    Logger.debug("Fetching cached summoner platform for #{puuid}... ")
    Redix.command!(redix_pid, ["GET", "summoner:#{puuid}:platform"])
  end

  @spec set_guild_channel(pid(), String.t(), String.t()) :: Redix.Protocol.redis_value()
  defp set_guild_channel(redix_pid, guild_id, channel_id) do
    Logger.debug("Writing channel ID #{channel_id} for guild ID #{guild_id}...")
    Redix.command!(redix_pid, ["SET", "guild:#{guild_id}:channel", channel_id])
  end

  @spec get_guild_channel(pid(), String.t()) :: Redix.Protocol.redis_value()
  defp get_guild_channel(redix_pid, guild_id) do
    Logger.debug("Fetching channel ID for guild ID #{guild_id}...")
    Redix.command!(redix_pid, ["GET", "guild:#{guild_id}:channel"])
  end

  @spec get_guild_ids_channels(pid(), list()) :: Redix.Protocol.redis_value()
  defp get_guild_ids_channels(redix_pid, guild_ids) do
    Logger.debug("Fetching channels IDs for #{length(guild_ids)} guilds...")
    keys = Enum.map(guild_ids, fn guild_id -> "guild:#{guild_id}:channel" end)

    Redix.command!(redix_pid, ["MGET" | keys])
  end

  @spec get_summoner_guilds(pid(), String.t()) :: Redix.Protocol.redis_value()
  defp get_summoner_guilds(redix_pid, puuid) do
    Logger.debug("Fetching guilds IDs for summoner #{puuid}...")
    Redix.command!(redix_pid, ["SMEMBERS", "summoner:#{puuid}:guilds"])
  end

  @spec set_summoner_nametag(pid(), String.t(), String.t(), String.t()) :: Redix.Protocol.redis_value()
  defp set_summoner_nametag(redix_pid, puuid, game_name, tag_line) do
    Logger.debug("Writing name #{game_name} and tag #{tag_line} for summoner #{puuid}...")
    Redix.pipeline!(redix_pid, [
      ["SET", "summoner:#{puuid}:name", game_name],
      ["SET", "summoner:#{puuid}:tag", tag_line]
    ])
  end

  @spec get_summoner_nametag(pid(), String.t()) :: {String.t(), String.t()}
  defp get_summoner_nametag(redix_pid, puuid) do
    Logger.debug("Fetching cached name and tag for summoner #{puuid}...")
    [game_name, tag_line] = Redix.pipeline!(redix_pid, [
      ["GET", "summoner:#{puuid}:name"],
      ["GET", "summoner:#{puuid}:tag"]
    ])
    {game_name, tag_line}
  end

  @spec set_summoner_icon_id(pid(), String.t(), integer()) :: Redix.Protocol.redis_value()
  defp set_summoner_icon_id(redix_pid, puuid, icon_id) do
    Logger.debug("Writing icon_id #{icon_id} for summoner #{puuid}...")
    Redix.command!(redix_pid, ["SET", "summoner:#{puuid}:icon_id", icon_id])
  end

  @spec get_summoner_icon_id(pid(), String.t()) :: integer()
  defp get_summoner_icon_id(redix_pid, puuid) do
    Logger.debug("Fetching icon_id for summoner #{puuid}...")
    Redix.command!(redix_pid, ["GET", "summoner:#{puuid}:icon_id"])
  end

  @spec set_summoner_id(pid(), String.t(), String.t()) :: Redix.Protocol.redis_value()
  defp set_summoner_id(redix_pid, puuid, summoner_id) do
    Logger.debug("Writing summoner_id #{summoner_id} for summoner #{puuid}...")
    Redix.command!(redix_pid, ["SET", "summoner:#{puuid}:id", summoner_id])
  end

  @spec get_summoner_id(pid(), String.t()) :: String.t()
  defp get_summoner_id(redix_pid, puuid) do
    Logger.debug("Fetching summoner_id for summoner #{puuid}...")
    Redix.command!(redix_pid, ["GET", "summoner:#{puuid}:id"])
  end
end
