defmodule Neurony.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :item_id, references(:items)
      add :filename, :string, null: false

      timestamps()
    end
  end
end
