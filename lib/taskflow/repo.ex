defmodule Taskflow.Repo do
  use Ecto.Repo,
    otp_app: :taskflow,
    adapter: Ecto.Adapters.Postgres
end
