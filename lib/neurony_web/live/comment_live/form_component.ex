defmodule NeuronyWeb.CommentLive.FormComponent do
  use NeuronyWeb, :live_component

  alias Neurony.Comment
  alias Neurony.Comments
  alias NeuronyWeb.CommentLive.CommentsComponent

  import NeuronyWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id={@id}
        phx-target={@myself}
        phx-change="change"
        phx-submit="save"
        hidden={@hidden}
      >
        <.input
          id={"comment-input-#{@id}"}
          field={@form[:body]}
          type="text"
          value={@comment_body}
          label="Leave a comment..."
        />
        <:actions>
          <.button
            phx-disable-with="Posting..."
            disabled={!@form.source.valid?}
            phx-click={toggle(@reply_to)}
          >
            Post Comment
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp toggle(comment) when is_nil(comment), do: nil

  defp toggle(comment) do
    JS.toggle(to: "#comment-form-#{comment.id}", in: "fade-in", out: "fade-out")
    |> JS.toggle(to: "#comment-reply-button-#{comment.id}", time: 0)
  end

  @impl true
  def update(assigns, socket) do
    changeset = Comment.changeset(%Comment{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:comment_body, nil)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("change", %{"comment" => comment_params}, socket) do
    changeset = Comment.changeset(%Comment{}, comment_params)

    {:noreply,
     socket
     |> assign_form(changeset)
     |> assign(:comment_body, comment_params["body"])}
  end

  @impl true
  def handle_event("save", %{"comment" => comment_params}, socket) do
    save_comment(socket, comment_params)
  end

  defp save_comment(socket, comment_params) do
    with {:ok, comment} <- Comments.post(socket.assigns, comment_params),
         comment <- Comment.load(comment, :parent) do
      notify_parent({:posted, comment})

      send_update(CommentsComponent,
        id: "replies-#{comment.parent_id}",
        comments: Comment.replies(comment.parent)
      )

      {:noreply,
       socket
       |> assign_form(Comment.changeset(%Comment{}, %{comment_body: nil}))
       |> assign(:comment_body, nil)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
