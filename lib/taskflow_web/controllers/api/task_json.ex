defmodule TaskflowWeb.API.TaskJSON do
  def index(%{tasks: tasks}) do
    %{data: for(task <- tasks, do: data(task))}
  end

  def data(task) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      inserted_at: task.inserted_at,
      updated_at: task.updated_at
    }
  end
end
