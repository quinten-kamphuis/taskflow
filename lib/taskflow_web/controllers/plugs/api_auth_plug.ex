defmodule TaskflowWeb.APIAuthPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- authenticate_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: "Invalid authorization token"})
        |> halt()
    end
  end

  defp authenticate_token(token) do
    # For demo purposes, we'll just check if the token matches the user's id
    # In a real app, you'd want to use proper token generation/validation
    case Taskflow.Repo.get_by(Taskflow.Accounts.User, id: token) do
      nil -> {:error, :invalid_token}
      user -> {:ok, user}
    end
  end
end
