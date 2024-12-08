defmodule TaskflowWeb.API.ProjectJSON do
  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  def data(project) do
    %{
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end
end
