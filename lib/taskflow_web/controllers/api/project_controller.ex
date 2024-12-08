defmodule TaskflowWeb.API.ProjectController do
  use TaskflowWeb, :controller

  alias Taskflow.Projects

  def index(conn, _params) do
    projects = Projects.list_user_projects(conn.assigns.current_user.id)
    render(conn, :index, projects: projects)
  end
end
