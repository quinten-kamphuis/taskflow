defmodule Taskflow.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "todo"
      add :priority, :string, null: false, default: "medium"
      add :due_date, :date

      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:tasks, [:project_id])
    create index(:tasks, [:user_id])
    create index(:tasks, [:status])
  end
end
