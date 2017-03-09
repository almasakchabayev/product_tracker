defmodule Account.ConnCase do
  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Account.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Account.Repo, {:shared, self()})
    end

    :ok
  end
end
