defmodule MyAppWeb.Admin.UserController do
  use MyAppWeb, :controller

  alias Plug.Conn
  alias Pow.{Plug, Operations}
  alias MyApp.Users

  plug :load_user when action in [:lock]

  # ...

  @spec lock(Conn.t(), map()) :: Conn.t()
  def lock(%{assigns: %{user: user}} = conn, _params) do
    case Users.lock(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User has been locked.")
        |> redirect(to: "/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "User couldn't be locked.")
        |> redirect(to: "/")
    end
  end

  defp load_user(%{params: %{"id" => user_id}} = conn, _opts) do
    config = Plug.fetch_config(conn)

    case Operations.get_by([id: user_id], config) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist")
        |> redirect(to: "/")

      user ->
        assign(conn, :user, user)
    end
  end
end
