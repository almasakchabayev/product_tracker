defmodule ProductTracker.ConnCase do
  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ProductTracker.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ProductTracker.Repo, {:shared, self()})
    end

    :ok
  end
end
