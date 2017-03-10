defmodule ProductTracker.Network do
  def get(_url, _, _opts) do
    {:ok, string} = File.read "fixtures/response.json"
     Poison.decode! string
  end
end
