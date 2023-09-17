defmodule Neurony.Repo.Migrations.AddItemComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :item_id, references(:items, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :body, :string, null: false
      add :parent_id, references(:comments, on_delete: :nothing)

      timestamps()
    end
  end
end
