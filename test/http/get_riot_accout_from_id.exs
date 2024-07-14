defmodule Tft_tracker_test.HttpClient.Get_riot_account_from_id do
  use ExUnit.Case

  test "get_riot_account_from_id works" do
    # Inexisting player case
    assert Tft_tracker.HttpClient.get_riot_account_from_id("ShouldNotExist", "NOT") == {:error, "HTTP GET request failed with status 404"}
    # Existing player case => pass
    assert Tft_tracker.HttpClient.get_riot_account_from_id("Chocobo", "3012") == {:ok, "5HokEg55dIIsVwRIHq57MwrYPbIXbTR2pSdGElZgTPIZ0NYsZJ0Yzwb8MAHr5amEkDP6mkDrpp1e8A"}
  end
end
