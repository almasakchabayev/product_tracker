defmodule ProductTracker.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :external_product_id, :integer
      add :price, :integer
      add :product_name, :string

      timestamps()
    end

    create unique_index(:products, [:external_product_id])
  end
end
