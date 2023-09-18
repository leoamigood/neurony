defmodule Neurony.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Neurony.Todos` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(user, attrs \\ %{}) do
    {:ok, item} =
      Neurony.Todos.create_item(
        user,
        attrs
        |> Enum.into(%{
          deadline: ~D[2023-09-13],
          description: "some description",
          priority: :low,
          title: "some title",
          completed: false
        })
      )

    item
  end
end
