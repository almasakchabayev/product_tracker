defmodule ProductTracker.ProductRecord do
  @moduledoc """
  Ecto Schema for casting and validating the external data
  with the structure of that data

  Module is also responsible for preparing data for
  inserting or updating
  """
  
  use Ecto.Schema

  import Ecto.Changeset

  alias ProductTracker.PastPriceRecord
  alias ProductTracker.Product

  @primary_key {:id, :integer, []}
  embedded_schema do
    field :category, :string
    field :discontinued, :boolean
    field :name, :string
    field :price, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:category, :discontinued, :id, :name, :price])
    |> validate_required([:discontinued, :id, :price, :name])
  end

  def to_product(product_record) do
    integer_price = normalize_price(product_record)
    
    %Product{external_product_id: Map.get(product_record, :id),
             price: integer_price,
             product_name: Map.get(product_record, :name)}
  end

  def to_product_changeset(product_record, product) do
    new_price = normalize_price(product_record)

    change product, price: new_price
  end

  def to_past_price_record(product_record, product) do
    new_price = normalize_price(product_record)
    percentage_change = (new_price - product.price) / product.price
    
    %PastPriceRecord{product_id: product.id,
                     price: product.price,
                     percentage_change: percentage_change}
  end

  def normalize_price(map) when is_map(map) do
    map
    |> Map.get(:price)
    |> normalize_price
  end

  @doc """
  Parses dollar amount into pennies

  ## Examples

      iex> ProductTracker.ProductRecord.normalize_price("$31.28")
      3128

      iex> ProductTracker.ProductRecord.normalize_price("$189.56")
      18956
  """
  def normalize_price(string) when is_binary(string) do
    {price, _} =
      string
      |> String.replace("$", "")
      |> String.replace(".", "")
      |> Integer.parse

    price
  end
end
