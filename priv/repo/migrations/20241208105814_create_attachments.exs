defmodule Taskflow.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :path, :string, null: false
      add :content_type, :string, null: false
      add :task_id, references(:tasks, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:attachments, [:task_id])
    create index(:attachments, [:user_id])
  end
end
