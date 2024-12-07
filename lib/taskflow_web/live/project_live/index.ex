defmodule TaskflowWeb.ProjectLive.Index do
  use TaskflowWeb, :live_view

  alias Taskflow.Projects
  alias Taskflow.Projects.Project

  defp status_color(status) do
    case status do
      "active" -> "bg-green-100 text-green-800"
      "completed" -> "bg-blue-100 text-blue-800"
      "archived" -> "bg-gray-100 text-gray-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Taskflow.PubSub, "user_projects:#{socket.assigns.current_user.id}")
    end

    projects = Projects.list_user_projects(socket.assigns.current_user.id)

    live_action = socket.assigns.live_action || :index

    {:ok,
     socket
     |> assign(:projects, projects)
     |> assign(:page_title, "Projects")
     |> assign(:live_action, live_action)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    project = Projects.get_user_project(socket.assigns.current_user.id, id)

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_user_project(socket.assigns.current_user.id, id)
    {:ok, _} = Projects.archive_project(project)

    {:noreply,
     assign(socket, :projects, Projects.list_user_projects(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_info({:project_updated, project}, socket) do
    {:noreply,
     update(socket, :projects, fn projects ->
       [project | Enum.reject(projects, &(&1.id == project.id))]
     end)}
  end
end
