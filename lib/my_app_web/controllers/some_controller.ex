defmodule MyAppWeb.SomeController do
  use MyAppWeb, :controller

  plug MyAppWeb.EnsureRolePlug, :admin

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
