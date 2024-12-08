defmodule Taskflow.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :task_id, references(:tasks, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:comments, [:task_id])
    create index(:comments, [:user_id])
  end
end
