defmodule ProductTracker.Mixfile do
  use Mix.Project

  def project do
    [app: :product_tracker,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ProductTracker.Application, []}]
  end

  @doc """
  Include test/support/conn_case.ex when testing
  """
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:ecto, "~> 2.1"}, # work with db
     {:postgrex, "~> 0.13.2"}, # adapter for ecto
     {:httpoison, "~> 0.11.1"}, # HTTP Client
     {:calendar, "~> 0.17.2"}, # date-time conveniences
     {:poison, "~> 3.1"}] # JSON handling
  end

  @doc """
  Ecto conveniences
  """
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
