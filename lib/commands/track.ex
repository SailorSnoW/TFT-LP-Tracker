defmodule Tft_tracker.Commands.Track do
  require Logger
  @behaviour Nosedrum.ApplicationCommand

  alias Tft_tracker.SummonerVerifier

  @impl true
  def description(), do: "Register and start tracking a TFT summoner from his Riot ID"

  @impl true
  def command(interaction) do
    options = interaction.data.options
    |> Enum.map(&{&1.name, &1.value})
    |> Enum.into(%{})

    case SummonerVerifier.verify_from_riot_name(options["game_name"], options["tag_line"], String.to_atom(options["platform"])) do
      {:ok, puuid} ->
        case GenServer.call(Tft_tracker.SummonersManager, {:register_summoner, puuid, options["platform"], interaction.guild_id}) do
          :ok ->
            [content: "✅ Successfuly started to track \"#{options["game_name"]}##{options["tag_line"]}\"."]
          {:error, reason} ->
            [content: reason]
        end
      :no_summoner_found ->
        [content: "❌ Summoner not found for \"#{options["game_name"]}##{options["tag_line"]}\" in #{String.upcase(options["platform"])}."]
    end
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "game_name",
        description: "The riot username before the tag name to start to track. (e.g: abcdef#1234 => abcdef)",
        required: true # Defaults to false if not specified.
      },
      %{
        type: :string,
        name: "tag_line",
        description: "The riot tag after the username and the # to start to track. (e.g: abcdef#1234 => 1234)",
        required: true # Defaults to false if not specified.
      },
      %{
        type: :string,
        name: "platform",
        description: "The platform/region of the account to track.",
        required: true, # Defaults to false if not specified.
        choices: [
          %{
            name: "BR",
            value: :br1
          },
          %{
            name: "EUNE",
            value: :eun1
          },
          %{
            name: "EUW",
            value: :euw1
          },
          %{
            name: "JP",
            value: :jp1
          },
          %{
            name: "KR",
            value: :kr
          },
          %{
            name: "LA1",
            value: :la1
          },
          %{
            name: "LA2",
            value: :la2
          },
          %{
            name: "NA",
            value: :na1
          },
          %{
            name: "OCE",
            value: :oc1
          },
          %{
            name: "TR",
            value: :tr1
          },
          %{
            name: "RU",
            value: :ru1
          },
        ]
      },
    ]
  end

  @impl true
  def type(), do: :slash
end
