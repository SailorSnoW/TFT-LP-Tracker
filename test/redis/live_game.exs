defmodule Tft_tracker_test.Redis.Live_game do
  use ExUnit.Case

  @test_puuid "123"
  @test_game_id "EUW1_1234"

  test "set, get and unset live game works" do
    # Try to get when not in live game
    assert GenServer.call(Tft_tracker.RedisWorker, {:get_live_game, @test_puuid}) == nil

    # Try to set live game to false when it is already false
    assert GenServer.call(Tft_tracker.RedisWorker, {:set_live_game, @test_puuid, false, ""}) == 0

    # Set in a live game
    assert GenServer.call(Tft_tracker.RedisWorker, {:set_live_game, @test_puuid, true, @test_game_id}) == "OK"

    # Try to get when in live game
    assert GenServer.call(Tft_tracker.RedisWorker, {:get_live_game, @test_puuid}) == @test_game_id

    # Unset in a live game
    assert GenServer.call(Tft_tracker.RedisWorker, {:set_live_game, @test_puuid, false, ""}) == 1
  end
end
