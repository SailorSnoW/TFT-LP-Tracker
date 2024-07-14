defmodule Tft_tracker.Types.Queues do

  @type t :: 1100 | 1160 | 1130

  @base_logo_url "https://ddragon.leagueoflegends.com/cdn/13.24.1/img/tft-queue/"

  def get_queue_string(queue_id) do
    case queue_id do
      1100 ->
        "Ranked"
      1130 ->
        "Hyper Roll"
      1160 ->
        "Double Up"
      _ ->
        "Unknown"
    end
  end

  def default(), do: 1100

  @spec is_ranked_queue?(t()) :: boolean()
  def is_ranked_queue?(queue_id) when queue_id in [1100, 1160, 1130] do
    true
  end

  def is_ranked_queue?(_queue_id) do
    false
  end

  def get_queue_logo_url(queue_id) do
    case queue_id do
      1100 ->
        "#{@base_logo_url}1100.png"
      1130 ->
        "#{@base_logo_url}1130.png"
      1160 ->
        "#{@base_logo_url}1160.png"
      _ ->
        "https://1.bp.blogspot.com/-z04ZEO8t-N0/XYJ0fapzxyI/AAAAAAABY4Q/UPm9lDlP9tkBZehJIfff6AmQ1L-YqWMuACLcBGAsYHQ/s1600/4368.jpg"
    end
  end
end
