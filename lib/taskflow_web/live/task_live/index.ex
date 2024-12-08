defmodule TaskflowWeb.TaskLive.Index do
  use TaskflowWeb, :live_view

  alias Taskflow.Tasks
  alias Taskflow.Tasks.Task
  alias Taskflow.Projects

  defp status_color(status) do
    case status do
      "todo" -> "bg-gray-100 text-gray-800"
      "in_progress" -> "bg-yellow-100 text-yellow-800"
      "in_review" -> "bg-blue-100 text-blue-800"
      "done" -> "bg-green-100 text-green-800"
    end
  end

  defp priority_color(priority) do
    case priority do
      "low" -> "bg-gray-100 text-gray-800"
      "medium" -> "bg-blue-100 text-blue-800"
      "high" -> "bg-yellow-100 text-yellow-800"
      "urgent" -> "bg-red-100 text-red-800"
    end
  end

  defp format_status(status) do
    status
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  @impl true
  def mount(%{"project_id" => project_id}, _session, socket) do
    # Ensure the project exists and belongs to the current user
    case Projects.get_user_project(socket.assigns.current_user.id, project_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Project not found")
         |> push_navigate(to: ~p"/projects")}

      project ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(Taskflow.PubSub, "project_tasks:#{project_id}")
        end

        {:ok,
         socket
         |> assign(:project, project)
         |> assign(:tasks, Tasks.list_project_tasks(project_id))
         |> assign(:page_title, "#{project.name} - Tasks")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    task = Tasks.get_project_task(socket.assigns.project.id, id)

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, task)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{project_id: socket.assigns.project.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "#{socket.assigns.project.name} - Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_project_task(socket.assigns.project.id, id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, assign(socket, :tasks, Tasks.list_project_tasks(socket.assigns.project.id))}
  end

  @impl true
  def handle_info({TaskflowWeb.TaskLive.FormComponent, {:saved, _task}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Task saved successfully")
     |> push_navigate(to: ~p"/projects/#{socket.assigns.project.id}/tasks")}
  end

  @impl true
  def handle_info({:task_updated, task}, socket) do
    {:noreply,
     update(socket, :tasks, fn tasks ->
       [task | Enum.reject(tasks, &(&1.id == task.id))]
     end)}
  end
end
