defmodule ProductTracker.Product do
  use Ecto.Schema

  schema "products" do
    field :external_product_id, :integer
    field :price, :integer
    field :product_name, :string
    has_many :past_price_records, ProductTracker.PastPriceRecord

    timestamps()
  end
end
