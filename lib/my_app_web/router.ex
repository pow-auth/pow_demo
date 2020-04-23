defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :maybe_check_password
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", MyAppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MyAppWeb.Telemetry
    end
  end

  defp maybe_check_password(conn, opts) do
    case conn.request_path == "/session" and conn.method == "POST" do
      true -> check_password(conn, opts)
      false -> conn
    end
  end

  alias MyAppWeb.Router.Helpers, as: Routes

  def check_password(%{params: %{"user" => user_params}} = conn, _opts) do
    changeset = MyApp.Users.User.changeset(%MyApp.Users.User{}, user_params)

    case changeset.errors[:password] do
      nil ->
        conn

      error ->
        msg = MyAppWeb.ErrorHelpers.translate_error(error)

        conn
        |> put_flash(:error, "You have to reset your password because it #{msg}")
        |> redirect(to: Routes.page_path(conn, :index))
        |> Plug.Conn.halt()
    end
  end
end
