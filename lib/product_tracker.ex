defmodule ProductTracker do
  @moduledoc """
  Documentation for ProductTracker.
  """

  require Logger
  
  alias ProductTracker.Product
  alias ProductTracker.ProductRecord
  alias ProductTracker.Repo

  @url "https://omegapricinginc.com/pricing/records.json"
  @api_key Application.get_env(:product_tracker, :omega_pricing_api_key)
  @network Application.get_env(:product_tracker, :network)

  def update_records do
    result =
      @network.get(@url, [], params: params())
      |> Map.get("productRecords")
    IO.inspect result
    @network.get(@url, [], params: params())
    |> Map.get("productRecords")
    |> Task.async_stream(__MODULE__, :process_record, [])
    |> Stream.run
  end

  def process_record(map) do
    # Validate input
    changeset = ProductRecord.changeset(%ProductRecord{}, map)

    if changeset.valid? do
      # If changeset is valid make a product_record
      product_record = Ecto.Changeset.apply_changes(changeset)

      # Try to get the product by external_product_id
      case Repo.get_by(Product, external_product_id: Map.get(map, "id")) do
        nil ->
          # if there is no such product then store to db
          insert_product(product_record)
        product ->
          # If there is such product then check if product name is the same
          if product.product_name == product_record.name do
            # If product name is the same then store past price record and update product
            insert_past_price_update_product(product_record)
          else
            # If product name is not the same then log error about mismatch
            Logger.error "Name mismatch \n#{inspect map} \n#{inspect product}"
          end
      end
    else
      # If changeset is invalid log error
      Logger.error "Invalid information is passed \n#{inspect map}"
    end
  end

  defp insert_product(product_record) do
    Logger.info "Creating a new product with the following information \n#{inspect product_record}"
    product_record
    |> ProductRecord.to_product
    |> Repo.insert!
  end

  defp insert_past_price_update_product(product_record) do
    Logger.info "Creating a new past price record and updating a product's price with the following information #{inspect product_record}"
    Repo.transaction fn ->
      # store past price record
      Repo.insert! ProductRecord.to_past_price_record(product_record, product)
      
      # Update product, update requires a changset
      Repo.update! ProductRecord.to_product_changeset(product_record, product)
    end
  end

  defp params do
    today = Calendar.Date.today! "Europe/London"
    # we can discuss how to go about subtracting one month
    one_month_ago = today |> Calendar.Date.subtract!(30)
    %{api_key: @api_key, start_date: today, end_date: one_month_ago}
  end
end
