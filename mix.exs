defmodule Tft_tracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :tft_tracker,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Tft_tracker.Main, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dotenvy, "~> 0.8.0"},
      {:redix, "~> 1.1"},
      {:req, "~> 0.5.0"},
      {:nostrum, "~> 0.9.1"},
      {:nosedrum, git: "https://github.com/jchristgit/nosedrum"}
    ]
  end
end
