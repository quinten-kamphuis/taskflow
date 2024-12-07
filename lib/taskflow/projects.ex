defmodule Taskflow.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Taskflow.Repo
  alias Taskflow.Projects.Project

  @doc """
  Returns the list of projects for a specific user.
  """
  def list_user_projects(user_id) do
    Project
    |> where(user_id: ^user_id)
    |> where([p], p.status != "archived")
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single project.
  Raises `Ecto.NoResultsError` if the Project does not exist.
  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Gets a single project owned by specific user.
  Returns nil if the project doesn't exist or doesn't belong to the user.
  """
  def get_user_project(user_id, id) do
    Project
    |> where(user_id: ^user_id)
    |> where(id: ^id)
    |> Repo.one()
  end

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.
  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Archives a project.
  """
  def archive_project(%Project{} = project) do
    update_project(project, %{status: "archived"})
  end

  @doc """
  Changes a project.
  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
