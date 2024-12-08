defmodule TaskflowWeb.API.TaskController do
  use TaskflowWeb, :controller

  alias Taskflow.Tasks
  alias Taskflow.Projects

  def index(conn, %{"project_id" => project_id}) do
    with {:ok, project} <- get_user_project(conn, project_id),
         tasks <- Tasks.list_project_tasks(project.id) do
      render(conn, :index, tasks: tasks)
    end
  end

  defp get_user_project(conn, project_id) do
    case Projects.get_user_project(conn.assigns.current_user.id, project_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Project not found"})
        |> halt()

      project ->
        {:ok, project}
    end
  end
end
