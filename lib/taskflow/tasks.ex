defmodule Taskflow.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Taskflow.Repo
  alias Taskflow.Tasks.Task
  alias Taskflow.Attachments.Attachment

  @doc """
  Returns the list of tasks for a specific project.
  """
  def list_project_tasks(project_id) do
    Task
    |> where(project_id: ^project_id)
    |> order_by([t], asc: t.status, desc: t.priority, desc: t.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single task.
  Raises `Ecto.NoResultsError` if the Task does not exist.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Gets a single task within a project.
  Returns nil if the task doesn't exist or doesn't belong to the project.
  """
  def get_project_task(project_id, id) do
    Task
    |> where(project_id: ^project_id)
    |> where(id: ^id)
    |> preload(:user)
    |> preload([:attachments, :user])
    |> Repo.one()
  end

  @doc """
  Creates a task.
  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.
  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a task's status.
  """
  def update_task_status(%Task{} = task, status) do
    update_task(task, %{status: status})
  end

  @doc """
  Deletes a task.
  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Changes a task.
  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    task
    |> Task.changeset(attrs)
  end

  def create_attachment(attrs \\ %{}) do
    %Attachment{}
    |> Attachment.changeset(attrs)
    |> Repo.insert()
  end

  def get_task_with_attachments(id) do
    Task
    |> where(id: ^id)
    |> preload([:attachments, :user])
    |> Repo.one()
  end
end
