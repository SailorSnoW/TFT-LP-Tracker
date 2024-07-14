defmodule Tft_tracker.Types.Regions do
  @moduledoc """
  An enum of possible usable regions for Riot API.
  """

  @type t :: :americas | :europe | :asia

  @regions [:americas, :europe, :asia, :sea]

  @doc """
  Checks if the given region is valid.
  """
  @spec valid?(any()) :: boolean()
  def valid?(region), do: region in @regions

  @doc """
  Returns the endpoint for a given region.
  """
  @spec endpoint(t()) :: String.t()
  def endpoint(:americas), do: "https://americas.api.riotgames.com"
  def endpoint(:europe), do: "https://europe.api.riotgames.com"
  def endpoint(:asia), do: "https://asia.api.riotgames.com"
  def endpoint(:sea), do: "https://sea.api.riotgames.com"
  def endpoint(_), do: (raise ArgumentError, "Invalid region")
end
