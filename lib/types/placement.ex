defmodule Tft_tracker.Types.Placement do
  @moduledoc """
  A type to define possible placement in a TFT game.
  """
  @type t :: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8

  @spec is_winner?(t()) :: boolean()
  def is_winner?(placement) when placement in [1, 2, 3, 4] do
    true
  end

  def is_winner?(_placement) do
    false
  end
end
