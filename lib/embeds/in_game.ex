defmodule Tft_tracker.Embeds.InGame do
  @moduledoc """
  Embedded discord message for currently in game Alerts.
  """
alias Tft_tracker.Types.Queues

  @profile_icon_url "https://ddragon.leagueoflegends.com/cdn/14.13.1/img/profileicon/"

  @spec create_embed(Queues.t(), String.t(), String.t()) :: Nostrum.Struct.Embed.t()
  def create_embed(queue_id, game_name, icon_id) do
    import Nostrum.Struct.Embed
    %Nostrum.Struct.Embed{}
    |> put_author("Game status", "", Queues.get_queue_logo_url(queue_id))
    |> put_title("TFT | In game (#{Queues.get_queue_string(queue_id)})")
    |> put_thumbnail("#{@profile_icon_url}#{icon_id}.png")
    |> put_description("**#{game_name}** is currently in a game.")
    |> put_timestamp("#{DateTime.utc_now() |> DateTime.to_iso8601()}")
    |> put_color(16744192)
  end
end
