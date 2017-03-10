defmodule ProductTrackerTest do
  use ProductTracker.ConnCase, async: true
  doctest ProductTracker

  import Ecto.Query

  alias ProductTracker.Product
  alias ProductTracker.ProductRecord
  alias ProductTracker.Repo

  setup do
    record = %{"category" => "home-furnishings",
               "discontinued" => false,
               "id" => random_id(),
               "name" => "Nice Chair",
               "price" => "$30.00"}

    {:ok, %{record: record}}
  end

  test "'process_record' creates a new product if there is NO product with external_product_id and the product is not discontinued", %{record: record} do
    # Process a record
    ProductTracker.process_record(record)

    # Get a product, that was supposed to be stored
    product = Repo.get_by!(Product, external_product_id: Map.get(record, "id"))

    # Assert fields
    assert product.id
    assert product.external_product_id == Map.get(record, "id")
  end

  test "'process_record' creates a new past_price_record if there is a product with external_product_id, it has the same name and the price is different", %{record: record} do
    # Make an existing product (put it in DB)
    product = %Product{external_product_id: Map.get(record, "id"),
                       price: Map.get(record, "price") |> ProductRecord.normalize_price,
                       product_name: Map.get(record, "name")}
    product = Repo.insert! product

    # Update price in a new record
    new_record = Map.put(record, "price", "$33.00")

    # Process new record
    ProductTracker.process_record(new_record)

    # Get an updated product with past_price_records
    query = from(Product, preload: [:past_price_records])
    updated_product = Repo.get_by!(query, external_product_id: Map.get(record, "id"))

    # Assert that the price has updated
    assert updated_product.price == ProductRecord.normalize_price(new_record["price"])
    
    # Assert that past_price_record has been stored
    [past_price_record] = updated_product.past_price_records
    assert past_price_record.id
    assert past_price_record.price == product.price
    assert past_price_record.percentage_change == 0.1
  end

  test "'process_record' logs an error if there is a matching external_product_id but with a different product name", %{record: record} do
    # Make an existing product (put it in DB)
    product = %Product{external_product_id: Map.get(record, "id"),
                       price: Map.get(record, "price") |> ProductRecord.normalize_price,
                       product_name: Map.get(record, "name")}
    product = Repo.insert! product

    # Update name in a new record
    new_record = Map.put(record, "name", "Something Else")
    
    # Update a price to fail the test, otherwise it won't fail
    new_record = Map.put(new_record, "price", "$33.00")

    # Process new record
    ProductTracker.process_record(new_record)

    # Get an updated product (which should not be updated)
    updated_product = Repo.get_by!(Product, external_product_id: Map.get(record, "id"))

    # Assert that nothing has changed
    assert product == updated_product
  end

  defp random_id do
    :rand.uniform(999999)
  end
end
