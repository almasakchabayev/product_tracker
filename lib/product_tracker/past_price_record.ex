defmodule ProductTracker.PastPriceRecord do
  use Ecto.Schema

  schema "past_price_records" do
    field :price, :integer
    field :percentage_change, :float
    belongs_to :product, ProductTracker.Product

    timestamps()
  end
end
