defmodule TaskflowWeb.TaskLive.TaskDetailsComponent do
  use TaskflowWeb, :live_component

  alias Taskflow.Comments
  alias Taskflow.Tasks

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:delete_modal_attachment_id, nil)
     |> assign(:comment_form, to_form(%{"content" => ""}))
     |> allow_upload(:attachment,
       accept: :any,
       max_entries: 5,
       max_file_size: Application.get_env(:taskflow, :max_upload_size),
       auto_upload: true,
       progress: &handle_progress/3
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

  @impl true
  def handle_event("validate", params, socket) do
    IO.puts("Validate event received: #{inspect(params)}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("upload_completed", _params, socket) do
    consume_uploaded_entries(socket, :attachment, fn %{path: path}, entry ->
      filename = "#{System.system_time(:second)}_#{entry.client_name}"
      dest = Path.join("priv/static/uploads", filename)

      File.cp!(path, dest)

      Tasks.create_attachment(%{
        filename: entry.client_name,
        path: "/uploads/#{filename}",
        content_type: entry.client_type,
        task_id: socket.assigns.task.id,
        user_id: socket.assigns.current_user.id
      })
    end)

    task = Tasks.get_task_with_attachments(socket.assigns.task.id)

    {:noreply, assign(socket, :task, task)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/projects/#{socket.assigns.project.id}/tasks")}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :attachment, ref)}
  end

  @impl true
  def handle_event("delete_attachment", %{"id" => id}, socket) do
    attachment = Enum.find(socket.assigns.task.attachments, &(&1.id == id))

    case Tasks.delete_attachment(attachment) do
      {:ok, _} ->
        task = Tasks.get_task_with_attachments(socket.assigns.task.id)
        {:noreply, assign(socket, :task, task)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete attachment")}
    end
  end

  @impl true
  def handle_event("show_delete_modal", %{"id" => id}, socket) do
    {:noreply, assign(socket, :delete_modal_attachment_id, id)}
  end

  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :delete_modal_attachment_id, nil)}
  end

  defp handle_progress(:attachment, entry, socket) do
    # Debug log
    IO.puts("Upload progress: #{entry.progress}%")

    if entry.progress == 100 do
      consume_uploaded_entries(socket, :attachment, fn %{path: path}, entry ->
        # Debug log
        IO.puts("Processing uploaded file: #{entry.client_name}")

        filename = "#{System.system_time(:second)}_#{entry.client_name}"
        dest = Path.join("priv/static/uploads", filename)

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        case Tasks.create_attachment(%{
               filename: entry.client_name,
               path: "/uploads/#{filename}",
               content_type: entry.client_type,
               task_id: socket.assigns.task.id,
               user_id: socket.assigns.current_user.id
             }) do
          {:ok, attachment} ->
            # Debug log
            IO.puts("Attachment created successfully")
            {:ok, attachment}

          {:error, changeset} ->
            # Debug log
            IO.puts("Error creating attachment: #{inspect(changeset)}")
            {:error, changeset}
        end
      end)

      task = Tasks.get_task_with_attachments(socket.assigns.task.id)
      {:noreply, assign(socket, :task, task)}
    else
      {:noreply, socket}
    end
  end
end
