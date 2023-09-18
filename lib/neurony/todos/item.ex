defmodule Neurony.Todos.Item do
  @moduledoc false

  use Ecto.Schema

  alias Neurony.Accounts.User
  alias Neurony.Document

  import Ecto.Changeset

  schema "items" do
    belongs_to :assigned_user, User
    has_many :documents, Document, on_delete: :delete_all

    field :deadline, :date
    field :description, :string
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :title, :string
    field :completed, :boolean

    timestamps()
  end

  def add_documents(item, documents) do
    Enum.each(documents, &Document.create(%{filename: &1}, item))
  end

  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, [:title, :description, :priority, :deadline, :completed, :assigned_user_id])
    |> validate_required([:title, :description, :priority, :deadline])
  end
end
