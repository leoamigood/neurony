defmodule Neurony.Comments do
  @moduledoc false

  alias Neurony.Comment

  def post(%{reply_to: nil, item: item, user: user}, comment_params) do
    Comment.create(comment_params, item, user)
  end

  def post(%{reply_to: comment, item: item, user: user}, comment_params) do
    Comment.create(comment_params, item, user, comment.id)
  end
end
