defmodule Tft_tracker_test.Summoner.SummonerLifetime do
  use ExUnit.Case

  @test_puuid "5HokEg55dIIsVwRIHq57MwrYPbIXbTR2pSdGElZgTPIZ0NYsZJ0Yzwb8MAHr5amEkDP6mkDrpp1e8A"

  test "summoner lifetime works" do
    GenServer.call(Tft_tracker.SummonersManager, {:start_summoner, @test_puuid})
    Process.sleep(60000)
  end
end
