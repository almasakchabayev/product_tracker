use Mix.Config

config :product_tracker, ProductTracker.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "product_tracker_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
