defmodule ProductTrackerTest do
  use ProductTracker.ConnCase, async: true
  doctest ProductTracker

  test "'process_record' creates a new product if there is NO product with external_product_id and the product is not discontinued" do
    record = %{"category" => "home-furnishings",
                "discontinued" => false,
                "id" => 123456,
                "name" => "Nice Chair",
                "price" => "$30.25"}
    {:ok, product} = ProductTracker.process_record(record)
    assert product.id
  end
end
