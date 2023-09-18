defmodule Neurony.Document do
  @moduledoc false

  use Ecto.Schema

  alias Neurony.Repo
  alias Neurony.Todos.Item

  import Ecto.Changeset

  schema "documents" do
    field :filename, :string
    belongs_to :item, Item

    timestamps()
  end

  def create(params, item) do
    changeset(%__MODULE__{}, params)
    |> put_assoc(:item, item)
    |> Repo.insert()
  end

  def changeset(document, attrs \\ %{}) do
    document
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
