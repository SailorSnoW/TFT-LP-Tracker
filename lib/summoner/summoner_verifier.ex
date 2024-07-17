defmodule Tft_tracker.SummonerVerifier do
  @moduledoc """
  Module that include some functions to ensure summoner data integrity
  """
  require Logger

  alias Tft_tracker.Types.Platforms
  alias Tft_tracker.HttpClient

  @spec verify_from_riot_name(String.t(), String.t(), Platforms.t()) :: {:ok, String.t(), String.t()} | :no_summoner_found
  def verify_from_riot_name(game_name, tag_line, platform) do
    Logger.debug("Checking if #{game_name}##{tag_line} is a valid TFT summoner in #{platform}... ")
    case HttpClient.get_riot_account_from_id(game_name, tag_line) do
      {:ok, puuid} ->
        Logger.debug("Got Riot account PUUID: #{puuid}")
        case HttpClient.get_summoner_from_puuid(puuid, platform) do
          {:ok, body} ->
            Logger.debug("Summoner found for PUUID: #{puuid} on #{platform}")
            summoner_id = body["id"]
            {:ok, puuid, summoner_id}
          :not_exist ->
            :no_summoner_found
        end
      :not_exist ->
        :no_summoner_found
    end
  end
end
