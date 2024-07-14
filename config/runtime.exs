import Config
import Dotenvy

source!([".env"])
  config :tft_tracker,
  api_key: env!("RIOT_API_KEY", :string),
  bot_token: env!("DISCORD_BOT_TOKEN", :string),
  redis_host: env!("REDIS_HOST", :string),
  redis_port: env!("REDIS_PORT", :string)

  config :nostrum,
  token: env!("DISCORD_BOT_TOKEN")
