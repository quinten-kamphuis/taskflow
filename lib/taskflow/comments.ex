defmodule Taskflow.Comments do
  import Ecto.Query
  alias Taskflow.Repo
  alias Taskflow.Comments.Comment

  def list_task_comments(task_id) do
    Comment
    |> where(task_id: ^task_id)
    |> order_by([c], desc: c.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end
end
