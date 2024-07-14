defmodule Tft_tracker_test.Summoner.SummonerLifetime do
  use ExUnit.Case

  @test_puuid "5HokEg55dIIsVwRIHq57MwrYPbIXbTR2pSdGElZgTPIZ0NYsZJ0Yzwb8MAHr5amEkDP6mkDrpp1e8A"
  @test_game_id "EUW1_7001461347"
  @test_platform :euw1
  @test_icon_id 6635

  test "summoner lifetime works" do
    {:ok, pid} = Tft_tracker.SummonerResultWorker.start_link([
      summoner_puuid: @test_puuid,
      platform: @test_platform,
      game_id: @test_game_id,
      icon_id: @test_icon_id
      ])
    wait_for_genserver_to_stop(pid)
  end

  defp wait_for_genserver_to_stop(pid) do
    if Process.alive?(pid) do
      Process.sleep(100)  # Attendre 100 ms avant de vérifier à nouveau
      wait_for_genserver_to_stop(pid)
    end
  end
end
