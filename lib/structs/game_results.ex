defmodule Tft_tracker.Structs.GameResults do
alias Tft_tracker.Structs.GameResults

  defstruct [
    :game_id,
    :queue_id,
    :last_round,
    :gold_left,
    :damage_dealt,
    :time_eliminated,
    :placement,
    :set_number
  ]

  @type game_id :: String.t() | nil

  @type last_round :: integer() | nil

  @type gold_left :: integer() | nil

  @type time_eliminated :: float() | nil

  @type damage_dealt :: integer() | nil

  @type queue_id :: integer() | nil

  @type placement :: integer() | nil

  @type set_number :: String.t() | nil

  @type t :: %__MODULE__{
    game_id: game_id(),
    queue_id: queue_id(),
    last_round: last_round(),
    damage_dealt: damage_dealt(),
    gold_left: gold_left(),
    time_eliminated: float(),
    placement: placement(),
    set_number: set_number()
  }

  @spec parse_from_body_response(map(), String.t()) :: GameResults.t()
  def parse_from_body_response(body, puuid) do
    participant = get_participant_info(body, puuid)
    %GameResults{
      game_id: body["info"]["gameId"],
      queue_id: body["info"]["queueId"],
      last_round: participant["last_round"],
      damage_dealt: participant["total_damage_to_players"],
      gold_left: participant["gold_left"],
      time_eliminated: participant["time_eliminated"],
      placement: participant["placement"],
      set_number: body["info"]["tft_set_number"]
    }
  end

  @spec get_participant_info(map(), String.t()) :: map()
  defp get_participant_info(body, puuid) do
    body["info"]["participants"]
    |> Enum.find(fn participant -> participant["puuid"] == puuid end)
  end
end
