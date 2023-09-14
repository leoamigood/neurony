defmodule Neurony.Todos.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :deadline, :date
    field :description, :string
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :title, :string
    field :assigned_user_id, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :description, :priority, :deadline])
    |> validate_required([:title, :description, :priority, :deadline])
  end
end
