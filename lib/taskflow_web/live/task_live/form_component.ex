defmodule TaskflowWeb.TaskLive.FormComponent do
  use TaskflowWeb, :live_component

  alias Taskflow.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage task records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="task-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[
            {"To Do", "todo"},
            {"In Progress", "in_progress"},
            {"In Review", "in_review"},
            {"Done", "done"}
          ]}
        />
        <.input
          field={@form[:priority]}
          type="select"
          label="Priority"
          options={[
            {"Low", "low"},
            {"Medium", "medium"},
            {"High", "high"},
            {"Urgent", "urgent"}
          ]}
        />
        <.input field={@form[:due_date]} type="date" label="Due date" />
        <.input
          field={@form[:user_id]}
          type="select"
          label="Assigned To"
          prompt="Select assignee"
          options={[{"Me", @current_user.id}]}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Task</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{task: task} = assigns, socket) do
    changeset = Tasks.change_task(task)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    # Always ensure project_id is set for new tasks
    task_params =
      if socket.assigns.action == :new do
        Map.put(task_params, "project_id", socket.assigns.project.id)
      else
        task_params
      end

    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    # Ensure project_id is set for new tasks
    task_params =
      if socket.assigns.action == :new do
        Map.put(task_params, "project_id", socket.assigns.project.id)
      else
        task_params
      end

    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
