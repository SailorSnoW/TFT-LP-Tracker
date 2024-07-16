defmodule Tft_tracker.Structs.LiveGameData do
  @moduledoc """
  Define the cached current game data for a summoner Worker.
  """
  alias Tft_tracker.Types.Queues
  defstruct [
    :timestamp,
    :game_id,
    in_game: false,
    icon_id: 0,
    queue_id: Queues.default()
  ]

  @type game_id :: String.t() | nil

  @type in_game :: boolean()

  @type icon_id :: integer()

  @type queue_id :: integer() | nil

  @type t :: %__MODULE__{
    game_id: game_id(),
    in_game: in_game(),
    queue_id: queue_id(),
    icon_id: icon_id()
  }
end
