# TFT LP Tracker

**TFT LP Tracker** is a Discord bot that alerts players and their friends about ongoing and completed ranked Teamfight Tactics (TFT) games. Configure alerts and track player performances using commands like `/set_channel` and `/track`. Powered by the official Riot API.

![Elixir](https://img.shields.io/badge/Elixir-4B275F?style=for-the-badge&logo=elixir&logoColor=white)
![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

## 📜 Features

- 🚨 **Real-time Game Alerts**: Get notified when registered players start or finish a ranked game.
- 📊 **Game Results**: Receive detailed summaries of game results, including stats and performance details.
- 🔧 **Easy Setup**: Set the alert channel with `/set_channel` and register players to track with `/track`.
- ⚡ **Powered by Riot API**: Utilizes the official Riot API to fetch game data.
- 🚀 **Blazing Fast**: Built with Elixir, leveraging lightweight processes for high concurrency and performance.

## 🚧 TODO

- ➕ Add the ability to untrack a player.
- 📈 Show player ranks, with LP gains and losses at the end of each game.
- 🔄 Rework logging (debug, info, notice...) for better clarity and structure.
- ⚙️ Optimize API requests to Riot to avoid rate limiting, crucial for scaling (currently not an issue for small communities).
- 👫 Display game partner in Double Up mode.
- And... REFACTOR CODEBASE A LOT (maybe)

I welcome all feature requests through GitHub issues!

## 🚀 Getting Started

### Prerequisites

- Docker and Docker Compose
- Riot API Key
- Redis

### Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/SailorSnoW/TFT-LP-Tracker.git
    cd TFT-LP-Tracker
    ```

2. **Set up your environment variables**:
    Create a `.env` based on `.env.example` file in the root directory and add your Riot API key and Bot Token:
    ```env
    RIOT_API_KEY=your_riot_api_key
    DISCORD_BOT_TOKEN=your_bot_token
    ```

3. **Run with Docker Compose**:
    ```bash
    docker-compose up --build
    ```

    This will spin up the bot along with a Redis instance for data persistence and caching.

### Platforms Supported

- Platforms supported by the Riot API

## 🛠️ Technologies Used

- **Elixir**: The main language used for bot development.
- **Nostrum**: Elixir library for Discord.
- **Redix**: Redis client for Elixir.
- **Req**: HTTP client for Elixir.
- **Docker**: Containerization of the bot and Redis.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue.

## ⚠️ Disclaimer

This bot is currently in alpha and is my first project in Elixir. The code quality may not be the best, and I'm open to any suggestions for improvement.

## 🤝 Acknowledgments

- Inspired by this LoL bot: [LP tracker](https://top.gg/bot/848983878601277442)
- Thanks to the developers of [Nostrum](https://hexdocs.pm/nostrum), [Redix](https://hexdocs.pm/redix), and [Req](https://hexdocs.pm/req) for their awesome libraries.
- Inspired by the need for a bot to handle multiple parallel tasks efficiently, which led to choosing Elixir.
