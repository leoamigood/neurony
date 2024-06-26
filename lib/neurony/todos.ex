defmodule Neurony.Todos do
  @moduledoc """
  The Todos context.
  """

  alias Neurony.Accounts
  alias Neurony.Repo
  alias Neurony.Todos.Item

  import Ecto.Changeset
  import Ecto.Query, warn: false

  def assignees do
    Accounts.list_users()
  end

  def reload!(item) do
    load_item!(item.id)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(%{priority: priority}) when priority in ["low", "medium", "high"] do
    items_query()
    |> where([t], t.priority == ^priority)
    |> Repo.all()
  end

  def list_items(_) do
    Repo.all(items_query())
  end

  defp items_query do
    from i in Item, order_by: [asc: i.inserted_at], preload: [:assigned_user]
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> load_item!(123)
      %Item{}

      iex> load_item!(456)
      ** (Ecto.NoResultsError)

  """
  def load_item!(id), do: Repo.get!(Item, id) |> Repo.preload([:assigned_user, :documents])
  def get_item(id), do: Repo.get(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(user, attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> put_assoc(:assigned_user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
