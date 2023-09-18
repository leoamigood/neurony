defmodule NeuronyWeb.ItemLive.Show do
  use NeuronyWeb, :live_view

  alias Neurony.Comment
  alias Neurony.Todos
  alias NeuronyWeb.ItemLive.Index

  import NeuronyWeb.Endpoint

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Todos.get_item(id) do
      nil ->
        {:ok, socket |> push_redirect(to: ~p"/items")}

      _ ->
        {:ok,
         socket
         |> stream(:items, Todos.list_items())
         |> assign(:assignees, Todos.assignees())}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:comments, Comment.item_comments(id))
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, Todos.load_item!(id))}
  end

  @impl true
  def handle_info({NeuronyWeb.CommentLive.FormComponent, {:posted, comment}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Comment posted successfully")
     |> push_patch(to: ~p"/items/#{comment.item_id}")}
  end

  @impl true
  def handle_info({NeuronyWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    broadcast_from!(self(), Index.todo_topic(), "saved", %{item: item})

    {:noreply, stream_insert(socket, :items, item)}
  end

  defp page_title(:show), do: "Show Task"
  defp page_title(:edit), do: "Edit Task"
end
