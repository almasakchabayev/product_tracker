defmodule ProductTracker.ProductRecord do
  @moduledoc """
  Ecto Schema for casting and validating the external data
  with the structure of that data
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
    integer_price =
      product_record
      |> Map.get(:price)
      |> normalize_price
    
    %Product{external_product_id: Map.get(product_record, :id),
             price: integer_price,
             product_name: Map.get(product_record, :name)}
  end

  def normalize_price(string) do
    {price, _} =
      string
      |> String.replace("$", "")
      |> String.replace(".", "")
      |> Integer.parse

    price
  end
end
