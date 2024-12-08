defmodule Taskflow.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string

    belongs_to :task, Taskflow.Tasks.Task
    belongs_to :user, Taskflow.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :task_id, :user_id])
    |> validate_required([:content, :task_id, :user_id])
    |> validate_length(:content, min: 1)
  end
end
