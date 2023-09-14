defmodule Neurony.Repo.Migrations.AddItemCompletedStatus do
  use Ecto.Migration

  def change do
    alter table("items") do
      add :completed, :boolean, default: false
    end
  end
end
