defmodule Tft_tracker_test.Redis.Summoner do
  use ExUnit.Case

  @test_puuid "123"
  @test_guild_id "789"
  @test_region :europe

  test "register_summoner, get summoners and unregister_summoner works" do
    assert GenServer.call(Tft_tracker.RedisWorker, {:register_summoner, @test_puuid, @test_region, @test_guild_id}) == :ok

    # Retrieve all tracked summoners
    assert GenServer.call(Tft_tracker.RedisWorker, {:get_tracked_summoners}) == ["123"]

    assert GenServer.call(Tft_tracker.RedisWorker, {:unregister_summoner, @test_puuid, @test_region, @test_guild_id}) == :ok

    # Retrieve all tracked summoners (empty)
    assert GenServer.call(Tft_tracker.RedisWorker, {:get_tracked_summoners}) == []
  end
end
