defmodule NeuronyWeb.ItemLive.Index do
  use NeuronyWeb, :live_view

  alias Neurony.Todos
  alias Neurony.Todos.Item

  import NeuronyWeb.Endpoint

  @todo_topic "todo"

  def todo_topic, do: @todo_topic

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: NeuronyWeb.Endpoint.subscribe(@todo_topic)
    {:ok,
      socket
      |> stream(:items, Todos.list_items())
      |> assign(:assignees, Todos.assignees())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    item = Todos.load_item!(id)
    broadcast_from!(self(), @todo_topic, "saved", %{item: item})

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:item, item)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_info({NeuronyWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    broadcast_from!(self(), @todo_topic, "saved", %{item: item})

    {:noreply, stream_insert(socket, :items, item)}
  end

  @impl true
  def handle_info(%{event: "saved", payload: %{item: item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end

  @impl true
  def handle_info(%{event: "deleted", payload: %{item: item}}, socket) do
    {:noreply, stream_delete(socket, :items, item)}
  end

  @impl true
  def handle_event("toggle", params, socket) do
    item = Todos.load_item!(params["toggle-id"])
    {:ok, item} = Todos.update_item(item, %{completed: params["value"] == "on"})

    broadcast_from!(self(), @todo_topic, "saved", %{item: item})

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Todos.load_item!(id)
    {:ok, _} = Todos.delete_item(item)

    broadcast_from!(self(), @todo_topic, "deleted", %{item: item})

    {:noreply, stream_delete(socket, :items, item)}
  end
end
