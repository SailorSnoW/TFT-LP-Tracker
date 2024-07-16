defmodule Tft_tracker.HttpClient do
  alias Tft_tracker.Types.Platforms
  alias Tft_tracker.Types.Regions
  alias Req.Response

  require Logger

  @spec get_riot_account_from_id(String.t(), String.t()) :: {:ok, String.t()} | :not_exist | {:error, String.t()}
  def get_riot_account_from_id(gameName, tagLine) do
    encoded_game_name = URI.encode(gameName)
    encoded_tag_line = URI.encode(tagLine)

    # Default to europe as the nearest endpoint
    req = Req.new(base_url: Regions.endpoint(:europe), headers: %{x_riot_token: get_api_key()})

    case Req.get(req, url: "/riot/account/v1/accounts/by-riot-id/#{encoded_game_name}/#{encoded_tag_line}") do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body["puuid"]}

      {:ok, %Response{status: status}} when status == 404 ->
        :not_exist

      {:ok, %Response{status: status, body: body}} ->
        Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
        {:error, "HTTP GET request failed with status #{status}"}

      {:error, reason} ->
        Logger.error("HTTP GET request failed: #{inspect(reason)}")
        {:error, "HTTP GET request failed: #{inspect(reason)}"}

    end
  end

  @spec get_gametag_from_puuid(String.t()) :: %{game_name: String.t(), tag_line: String.t()} | :not_found
  def get_gametag_from_puuid(puuid) do
    url = "/riot/account/v1/accounts/by-puuid/#{puuid}"
    # Default to europe as the nearest endpoint
    req = Req.new(base_url: Regions.endpoint(:europe), headers: %{x_riot_token: get_api_key()})

    case Req.get!(req, url: url) do
      %Response{status: status, body: body} when status in 200..299 ->
        %{game_name: body["gameName"], tag_line: body["tagLine"]}

      %Response{status: status} when status == 404 ->
        :not_found

      %Response{status: status, body: body} ->
        Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
        {:error, "HTTP GET request failed with status #{status}"}
    end
  end

  @spec get_summoner_from_puuid(
          any(),
          Platforms.t()
        ) :: :not_exist | {:error, String.t()} | {:ok, any()}
  def get_summoner_from_puuid(puuid, platform) do
    url = "/tft/summoner/v1/summoners/by-puuid/#{puuid}"
    req = Req.new(base_url: Platforms.endpoint(platform), headers: %{x_riot_token: get_api_key()})

    case Req.get(req, url: url) do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

        {:ok, %Response{status: status}} when status == 404 ->
          :not_exist

        {:ok, %Response{status: status, body: body}} ->
          Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
          {:error, "HTTP GET request failed with status #{status}"}

        {:error, reason} ->
          Logger.error("HTTP GET request failed: #{inspect(reason)}")
          {:error, "HTTP GET request failed: #{inspect(reason)}"}
    end
  end

  @spec get_current_game_infos(String.t(), Platforms.t()) :: map() | :not_in_game
  def get_current_game_infos(puuid, platform) do
    url = "/lol/spectator/tft/v5/active-games/by-puuid/#{puuid}"
    req = Req.new(base_url: Platforms.endpoint(platform), headers: %{x_riot_token: get_api_key()})

    case Req.get!(req, url: url) do
      %Response{status: status, body: body} when status in 200..299 ->
        body

      %Response{status: status} when status == 404 ->
        :not_in_game

      %Response{status: status, body: body} ->
        Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
        raise("HTTP GET request failed with status #{status}")
    end
  end

  @spec get_match_result(
          String.t(),
          Platforms.t()
        ) :: map() | :not_found
  def get_match_result(match_id, platform) do
    region = Platforms.region(platform)
    endpoint = Regions.endpoint(region)
    url = "/tft/match/v1/matches/#{match_id}"
    req = Req.new(base_url: endpoint, headers: %{x_riot_token: get_api_key()})

    case Req.get!(req, url: url) do
      %Response{status: status, body: body} when status in 200..299 ->
        body

      %Response{status: status} when status == 404 ->
        :not_found

      %Response{status: status, body: body} ->
        Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
        raise("HTTP GET request failed with status #{status}")
    end
  end

  defp get_api_key() do
    Application.get_env(:tft_tracker, :api_key)
  end
end
