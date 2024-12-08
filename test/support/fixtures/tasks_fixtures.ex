defmodule Taskflow.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Taskflow.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~D[2024-12-06],
        priority: "some priority",
        status: "some status",
        title: "some title"
      })
      |> Taskflow.Tasks.create_task()

    task
  end
end
