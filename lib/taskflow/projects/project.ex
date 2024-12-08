defmodule Taskflow.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "active"

    belongs_to :user, Taskflow.Accounts.User

    has_many :tasks, Taskflow.Tasks.Task

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :status, :user_id])
    |> validate_required([:name, :status, :user_id])
    |> validate_inclusion(:status, ["active", "completed", "archived"])
    |> validate_length(:name, min: 3, max: 100)
  end
end
