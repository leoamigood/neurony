defmodule Neurony.Comment do
  @moduledoc false

  use Ecto.Schema
  use Arbor.Tree

  alias Neurony.Accounts.User
  alias Neurony.Repo
  alias Neurony.Todos.Item

  import Ecto.Changeset
  import Ecto.Query

  schema "comments" do
    field :body, :string
    belongs_to :item, Item
    belongs_to :user, User
    belongs_to :parent, __MODULE__

    timestamps()
  end

  def item_comments(id) do
    roots()
    |> where([t], t.item_id == ^id)
    |> order_by([t], desc: t.inserted_at)
    |> preload(:user)
    |> Repo.all
  end

  def replies(comment) when is_nil(comment), do: []
  def replies(comment) do
    comment
    |> children
    |> order_by([t], desc: t.inserted_at)
    |> preload(:user)
    |> Repo.all
  end

  def create(params, item, user, parent_id \\ nil) do
    changeset(%__MODULE__{}, params)
    |> Ecto.Changeset.put_change(:parent_id, parent_id)
    |> Ecto.Changeset.put_assoc(:item, item)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def load(comment, association) do
    comment |> Repo.preload(association)
  end

  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, [:body, :parent_id])
    |> validate_required([:body])
  end
end
