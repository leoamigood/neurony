defmodule NeuronyWeb.CommentLive.CommentsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
      <div id={@root}>
        <%= for comment <- @comments do %>
          <.live_component
            module={NeuronyWeb.CommentLive.CommentComponent}
            id={"comment-#{comment.id}"}
            comment={comment}
            item={@item}
            user={@user}
          />
        <% end %>
      </div>
    """
  end
end
