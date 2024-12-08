defmodule Taskflow.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "todo"
    field :priority, :string, default: "medium"
    field :due_date, :date

    belongs_to :project, Taskflow.Projects.Project
    belongs_to :user, Taskflow.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :due_date, :project_id, :user_id])
    |> validate_required([:title, :status, :priority, :project_id])
    |> validate_inclusion(:status, ["todo", "in_progress", "in_review", "done"])
    |> validate_inclusion(:priority, ["low", "medium", "high", "urgent"])
    |> validate_length(:title, min: 3, max: 100)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end
end
