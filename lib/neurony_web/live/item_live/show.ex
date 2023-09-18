defmodule NeuronyWeb.ItemLive.Show do
  use NeuronyWeb, :live_view

  alias Neurony.Comment
  alias Neurony.Todos
  alias Neurony.Todos.Item
  alias NeuronyWeb.ItemLive.Index
  alias Phoenix.VerifiedRoutes

  import NeuronyWeb.Endpoint

  @uploads_dir Path.expand("../../../priv/uploads", __DIR__)
  @max_total_documents 5

  def max_total_documents, do: @max_total_documents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Todos.get_item(id) do
      nil ->
        {:ok, socket |> push_redirect(to: ~p"/items")}

      item ->
        {:ok,
         socket
         |> stream(:items, Todos.list_items(%{}))
         |> assign_form(Item.changeset(item))}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    item = Todos.load_item!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, item)
     |> assign(:assignees, Todos.assignees())
     |> assign(:comments, Comment.item_comments(id))
     |> assign(:total_documents, length(item.documents))
     |> allow_upload(:documents,
       accept: ~w(.pdf .doc .docx),
       max_entries: 1
     )}
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

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, %{assigns: %{item: item}} = socket) do
    File.mkdir_p!(@uploads_dir)
    case uploaded_entries(socket, :documents) do
      {[_ | _] = entries, []} ->
        uploaded_files =
          for entry <- entries do
            consume_uploaded_entry(socket, entry, fn %{path: path} ->
              dest = Path.join(@uploads_dir, Path.basename(path)) |> IO.inspect
              File.cp!(path, dest)
              {:ok, VerifiedRoutes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
            end)
          end

        Item.add_documents(item, uploaded_files)

        {:noreply,
         socket
         |> update(:total_documents, &(&1 + length(uploaded_files)))
         |> put_flash(:info, "Document uploaded successfully!")}

      _ ->
        {:noreply, socket}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp page_title(:show), do: "Show Task"
  defp page_title(:edit), do: "Edit Task"
end
