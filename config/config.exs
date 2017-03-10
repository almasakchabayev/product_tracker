use Mix.Config

config :product_tracker,
  ecto_repos: [ProductTracker.Repo]

config :product_tracker, omega_pricing_api_key: "abc123key"

# mock httpoison
config :product_tracker, network: ProductTracker.Network

import_config "#{Mix.env}.exs"
