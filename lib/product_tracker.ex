defmodule ProductTracker do
  @moduledoc """
  Documentation for ProductTracker.
  """

  require Logger
  
  alias ProductTracker.ProductRecord
  alias ProductTracker.Repo

  @url "https://omegapricinginc.com/pricing/records.json"
  @api_key Application.get_env(:product_tracker, :omega_pricing_api_key)
  @network Application.get_env(:product_tracker, :network)

  def update_records do
    @network.get(@url, [], params: params())
    |> Map.get("productRecords")
    |> Task.async_stream(__MODULE__, :process_record, [])
  end

  def process_record(map) do
    changeset = ProductRecord.changeset(%ProductRecord{}, map)

    # add an if statement for existing_product_id
    if changeset.valid? do
      Logger.info "Creating a new product with the following information #{inspect map}"
      
      Ecto.Changeset.apply_changes(changeset)
      |> ProductRecord.to_product
      |> Repo.insert
      |> case do
           {:ok, product} -> {:ok, product}
           {:error, changeset} -> {:error, changeset}
      end
    end
  end

  defp params do
    today = Calendar.Date.today! "Europe/London"
    # we can discuss how to go about subtracting one month
    one_month_ago = today |> Calendar.Date.subtract!(30)
    %{api_key: @api_key, start_date: today, end_date: one_month_ago}
  end
end
