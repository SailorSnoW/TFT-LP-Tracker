defmodule Tft_tracker.Embeds.ResultGame do
  @moduledoc """
  Embedded discord message for currently in game Alerts.
  """

  alias Tft_tracker.Structs.GameResults
  alias Tft_tracker.Types.Platforms
  alias Tft_tracker.Types.Queues
  alias Tft_tracker.Types.Placement

  @profile_icon_url "https://ddragon.leagueoflegends.com/cdn/14.13.1/img/profileicon/"
  @match_result_url "https://tracker.gg/tft/match/"

  @spec create_embed(
          Platforms.t(),
          String.t(),
          integer(),
          GameResults.t()
        ) :: Nostrum.Struct.Embed.t()
  def create_embed(
    platform,
    game_name,
    icon_id,
    game_result_data
    ) do
    import Nostrum.Struct.Embed
    %Nostrum.Struct.Embed{}
    |> put_author("Game results", "", Queues.get_queue_logo_url(game_result_data.queue_id))
    |> put_title("#{get_result_title(game_result_data.placement, game_result_data.queue_id)}")
    |> put_url("#{@match_result_url}#{Platforms.tft_tracker_website_platform(platform)}/#{String.upcase(to_string(platform))}_#{game_result_data.game_id}")
    |> put_thumbnail("#{@profile_icon_url}#{icon_id}.png")
    |> put_description(get_result_description(game_name, game_result_data.placement, game_result_data.queue_id))
    |> put_field("Queue", Queues.get_queue_string(game_result_data.queue_id))
    |> put_field("Gold Left", "#{game_result_data.gold_left}", true)
    |> put_field("Rounds Survived", "#{game_result_data.last_round}", true)
    |> put_field("Damage Dealt", "#{game_result_data.damage_dealt}", true)
    |> put_timestamp("#{DateTime.utc_now() |> DateTime.to_iso8601()}")
    |> put_footer("Set #{game_result_data.set_number}")
    |> put_color(get_result_color(game_result_data.placement))
  end

  @spec get_result_title(Placement.t(), Queues.t()) :: String.t()
  defp get_result_title(placement, queue_id) do
    if queue_id == 1160 do
      # Double Up results format
      case placement do
        1 -> "__1st place__ 🏆"
        2 -> "__1st place__ 🏆"
        3 -> "__2nd place__ 🥈"
        4 -> "__2nd place__ 🥈"
        5 -> "__3rd place__"
        6 -> "__3rd place__"
        7 -> "__4th place__"
        8 -> "__4th place__"
      end
    else
      case placement do
        1 -> "__1st place__ 🏆"
        2 -> "__2nd place__ 🥈"
        3 -> "__3rd place__ 🥉"
        4 -> "__4th place__ 😎"
        5 -> "__5th place__"
        6 -> "__6th place__"
        7 -> "__7th place__"
        8 -> "__8th place__"
      end
    end
  end

  @spec get_result_description(String.t(), Placement.t(), Queues.t()) :: String.t()
  def get_result_description(game_name, placement, queue_id) do
    if Placement.is_winner?(placement) do
      "**#{game_name}** just finished at the #{get_result_title(placement, queue_id)}!"
    else
      "**#{game_name}** just finished at the #{get_result_title(placement, queue_id)}!"
    end
  end

  @spec get_result_color(Placement.t()) :: integer()
  def get_result_color(placement) do
    if Placement.is_winner?(placement) do
      7982667
    else
      12336438
    end
  end
end
