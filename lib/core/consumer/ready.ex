defmodule Tft_tracker.Consumer.Ready do
  require Logger
  @moduledoc "Handles the `READY` event."

  alias Tft_tracker.Commands
  alias Nostrum.Api

  @commands %{
    "track" => Commands.Track,
    "set_channel" => Commands.SetChannel,
  }

  @spec handle(map()) :: :ok
  def handle(data) do
    Enum.each(data.guilds, fn guild ->
      :ok = load_commands(guild.id)
    end)
    Logger.notice("⚡ Logged in and ready, seeing `#{length(data.guilds)}` guilds.")
    :ok = Api.update_status(:online, "Teamfight Tactics")
  end

  defp load_commands(guild_id) do
    [@commands]
    |> Stream.concat()
    |> Enum.each(&load_command(&1, guild_id))
  end

  defp load_command({name, cog}, guild_id) do
    case is_map(cog) do
      # It's a command with subcommands
      true ->
        Enum.each(cog, fn {subname, module} ->
          Nosedrum.Storage.Dispatcher.add_command([name, subname], module, guild_id)
        end)

      # It's a plain command
      false ->
        Nosedrum.Storage.Dispatcher.add_command(name, cog, guild_id)
    end
  end
end
