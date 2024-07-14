defmodule Tft_tracker.CommandHandler do
  use Nostrum.Consumer
  require Logger

  alias Tft_tracker.Consumer
  alias Nosedrum.Storage.Dispatcher

  # Because we're shifting almost all the work of handling commands off to Nosedrum
  # we don't need to do anything more than load our commands, then pass any interaction_create
  # messages off to Nosedrum.Storage.Dispatcher
  def handle_event({:READY, data, _ws_state}), do: Consumer.Ready.handle(data)
  def handle_event({:INTERACTION_CREATE, intr, _}), do: Dispatcher.handle_interaction(intr)
  def handle_event(_), do: :noop
end
