defmodule Tft_tracker.Types.Platforms do
@moduledoc """
  An enum of possible usable platforms for Riot API.
  """
alias Tft_tracker.Types.Regions

@type t :: :br1 | :eun1 | :euw1 | :jp1 | :kr | :la1 | :la2 | :na1 | :oc1 | :tr1 | :ru

@platforms [:br1, :eun1, :euw1, :jp1, :kr, :la1, :la2, :na1, :oc1, :tr1, :ru]

  @doc """
  Checks if the given region is valid.
  """
  @spec valid?(any()) :: boolean()
  def valid?(platform), do: platform in @platforms

  @doc """
  Returns the endpoint for a given region.
  """
  @spec endpoint(t()) :: String.t()
  def endpoint(platform) when platform in @platforms, do: "https://#{platform}.api.riotgames.com"

  @spec region(t()) :: Regions.t()
  def region(platform) when platform in @platforms do
    cond do
      is_americas(platform) -> :americas
      is_europe(platform) -> :europe
      is_asia(platform) -> :asia
      is_oceania(platform) -> :sea
    end
  end

  @spec tft_tracker_website_platform(t()) :: String.t()
  def tft_tracker_website_platform(platform) when platform in @platforms do
    case platform do
      :br1 -> "BR"
      :eun1 -> "EUNE"
      :euw1 -> "EUW"
      :jp1 -> "JP"
      :kr -> "KR"
      :la1 -> "LAN"
      :la2 -> "LAS"
      :na1 -> "NA"
      :oc1 -> "OCE"
      :tr1 -> "TR"
      :ru -> "RU"
    end
  end

  defp is_americas(platform), do: platform in [:na1, :br1, :la1, :la2]
  defp is_europe(platform), do: platform in [:euw1, :eun1, :ru, :tr1]
  defp is_asia(platform), do: platform in [:kr, :jp1]
  defp is_oceania(platform), do: platform in [:oc1]

end
