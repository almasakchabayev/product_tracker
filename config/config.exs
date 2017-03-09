use Mix.Config

config :product_tracker,
  ecto_repos: [ProductTracker.Repo]

import_config "#{Mix.env}.exs"
