defmodule Neurony.TodosTest do
  use Neurony.DataCase

  alias Neurony.Todos

  import Neurony.AccountsFixtures

  describe "items" do
    alias Neurony.Todos.Item

    import Neurony.TodosFixtures

    @invalid_attrs %{deadline: nil, description: nil, priority: nil, title: nil}

    setup do
      %{user: user_fixture()}
    end

    test "list_items/0 returns all items", %{user: user} do
      item = item_fixture(user)
      assert Todos.list_items() == [item]
    end

    test "load_item!/1 returns the item with given id", %{user: user} do
      item = item_fixture(user)
      assert Todos.load_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item", %{user: user} do
      valid_attrs = %{deadline: ~D[2023-09-13], description: "some description", priority: :low, title: "some title"}

      assert {:ok, %Item{} = item} = Todos.create_item(user, valid_attrs)
      assert item.deadline == ~D[2023-09-13]
      assert item.description == "some description"
      assert item.priority == :low
      assert item.title == "some title"
    end

    test "create_item/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Todos.create_item(user, @invalid_attrs)
    end

    test "update_item/2 with valid data updates the item", %{user: user} do
      item = item_fixture(user)
      update_attrs = %{deadline: ~D[2023-09-14], description: "some updated description", priority: :medium, title: "some updated title"}

      assert {:ok, %Item{} = item} = Todos.update_item(item, update_attrs)
      assert item.deadline == ~D[2023-09-14]
      assert item.description == "some updated description"
      assert item.priority == :medium
      assert item.title == "some updated title"
    end

    test "update_item/2 with invalid data returns error changeset", %{user: user} do
      item = item_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Todos.update_item(item, @invalid_attrs)
      assert item == Todos.load_item!(item.id)
    end

    test "delete_item/1 deletes the item", %{user: user} do
      item = item_fixture(user)
      assert {:ok, %Item{}} = Todos.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Todos.load_item!(item.id) end
    end

    test "change_item/1 returns a item changeset", %{user: user} do
      item = item_fixture(user)
      assert %Ecto.Changeset{} = Todos.change_item(item)
    end
  end
end
