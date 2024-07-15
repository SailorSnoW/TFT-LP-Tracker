# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

config :nostrum,
  num_shards: :auto

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:module, :summoner]
