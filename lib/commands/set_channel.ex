defmodule Tft_tracker.Commands.SetChannel do
  require Logger
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description(), do: "Set the current channel as the bot's alert posting channel."

  @impl true
  def command(interaction) do
    GenServer.call(Tft_tracker.RedisWorker, {:set_guild_channel, interaction.guild_id, interaction.channel_id})
    [content: "✅ Channel set to ##{interaction.channel.name}."]
  end

  @impl true
  def type(), do: :slash
end
