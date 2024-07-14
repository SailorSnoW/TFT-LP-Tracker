defmodule Tft_tracker.AlertsDispatcher do
  require Logger

  alias Nostrum.Api

  @spec dispatch_embed(Nostrum.Struct.Embed.t(), list()) :: term()
  def dispatch_embed(embed, channel_ids) do
    Enum.each(channel_ids, fn channel_id ->
      Logger.debug("Dispatching new embed to channel #{channel_id}")
      Task.start(fn -> Api.create_message!(String.to_integer(channel_id), embeds: [embed]) end)
    end)
  end
end
