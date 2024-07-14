defmodule Tft_tracker_test.HttpClient.Get_current_game_infos do
  use ExUnit.Case

  @test_puuid "5HokEg55dIIsVwRIHq57MwrYPbIXbTR2pSdGElZgTPIZ0NYsZJ0Yzwb8MAHr5amEkDP6mkDrpp1e8A"
  @test_platform :euw1

  test "get_current_game_infos works" do
    # Should not be in game or in game, but no errors should appear with a valid api key
    assert Tft_tracker.HttpClient.get_current_game_infos(@test_puuid, @test_platform) == :not_in_game or {:ok, ""}
  end
end
