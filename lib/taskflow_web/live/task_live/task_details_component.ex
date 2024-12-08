defmodule TaskflowWeb.TaskLive.TaskDetailsComponent do
  use TaskflowWeb, :live_component

  alias Taskflow.Comments

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:comment_form, to_form(%{"content" => ""}))
     |> allow_upload(:attachment,
       accept: :any,
       max_entries: 5,
       max_file_size: Application.get_env(:taskflow, :max_upload_size)
     )}
  end

  @impl true
  @spec update(%{:task => any(), optional(any()) => any()}, any()) :: {:ok, map()}
  def update(%{task: task} = assigns, socket) do
    comments = Comments.list_task_comments(task.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:comments, comments)}
  end

  @impl true
  def handle_event("save_comment", %{"content" => content}, socket) do
    params = %{
      content: content,
      task_id: socket.assigns.task.id,
      user_id: socket.assigns.current_user.id
    }

    case Comments.create_comment(params) do
      {:ok, comment} ->
        {:noreply,
         socket
         |> assign(:comments, [
           %{comment | user: socket.assigns.current_user} | socket.assigns.comments
         ])
         |> assign(:comment_form, to_form(%{"content" => ""}))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not save comment")}
    end
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/projects/#{socket.assigns.project.id}/tasks")}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :attachment, ref)}
  end
end
