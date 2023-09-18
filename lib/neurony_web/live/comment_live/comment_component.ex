defmodule NeuronyWeb.CommentLive.CommentComponent do
  use Phoenix.LiveComponent

  alias Neurony.Comment
  alias Phoenix.LiveView.JS

  import NeuronyWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div id={"comment-#{@comment.id}"} style="padding-left: 25px;">
      <%= @comment.body %> • by <%= @comment.user.email %>
      <.button id={"comment-reply-button-#{@comment.id}"} phx-click={toggle(@comment)}>Reply</.button>

      <.live_component
        module={NeuronyWeb.CommentLive.FormComponent}
        id={"comment-form-#{@comment.id}"}
        reply_to={@comment}
        item={@item}
        user={@user}
        hidden={true}
      />

      <.live_component
        module={NeuronyWeb.CommentLive.CommentsComponent}
        id={"replies-#{@comment.id}"}
        comments={Comment.replies(@comment)}
        item={@item}
        user={@user}
        root={"replies-#{@comment.id}"}
      />
    </div>
    """
  end

  defp toggle(comment) do
    JS.toggle(to: "#comment-form-#{comment.id}", in: "fade-in", out: "fade-out")
    |> JS.toggle(to: "#comment-reply-button-#{comment.id}", time: 0)
    |> JS.focus(to: "#comment-input-comment-form-#{comment.id}")
  end
end
