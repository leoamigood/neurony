defmodule Neurony.Todos.Item do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Neurony.Accounts.User

  schema "items" do
    belongs_to :assigned_user, User

    field :deadline, :date
    field :description, :string
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :title, :string
    field :completed, :boolean

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :description, :priority, :deadline, :completed])
    |> validate_required([:title, :description, :priority, :deadline])
  end
end
