defmodule ProductTracker.IntegrationTest do
  use ProductTracker.ConnCase

  alias ProductTracker.Product
  alias ProductTracker.Repo
  
  test "'update_records' fetches records from client's api, creates/updates records" do
    ProductTracker.update_records

    products = Repo.all Product
    assert length(products) == 2
  end
end
