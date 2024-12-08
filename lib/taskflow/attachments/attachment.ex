defmodule Taskflow.Attachments.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "attachments" do
    field :filename, :string
    field :path, :string
    field :content_type, :string

    belongs_to :task, Taskflow.Tasks.Task
    belongs_to :user, Taskflow.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :path, :content_type, :task_id, :user_id])
    |> validate_required([:filename, :path, :content_type, :task_id, :user_id])
  end
end
