defmodule Neurony.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :string
      add :description, :text
      add :priority, :string
      add :deadline, :date
      add :assigned_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:assigned_user_id])
  end
end
