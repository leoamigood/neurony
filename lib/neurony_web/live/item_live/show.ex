defmodule NeuronyWeb.ItemLive.Show do
  use NeuronyWeb, :live_view

  alias Neurony.Todos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:assignees, Todos.assignees())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, Todos.get_item!(id))}
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
