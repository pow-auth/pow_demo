defmodule MyAppWeb.EnsureUserNotLockedPlugTest do
  use MyAppWeb.ConnCase

  alias MyApp.Users.User
  alias MyAppWeb.EnsureUserNotLockedPlug

  @pow_config [otp_app: :my_app]
  @user %User{id: 1, locked_at: nil}
  @locked_user %User{id: 2, locked_at: DateTime.utc_now()}
  @plug_opts []

  setup do
    {:ok, conn: init_conn()}
  end

  test "call/2 with no user", %{conn: conn} do
    opts = EnsureUserNotLockedPlug.init(@plug_opts)
    conn = EnsureUserNotLockedPlug.call(conn, opts)

    refute conn.halted
  end

  test "call/2 with user", %{conn: conn} do
    opts = EnsureUserNotLockedPlug.init(@plug_opts)
    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, @pow_config)
      |> EnsureUserNotLockedPlug.call(opts)

    refute conn.halted
  end

  test "call/2 with locked user", %{conn: conn} do
    opts = EnsureUserNotLockedPlug.init(@plug_opts)
    conn =
      conn
      |> Pow.Plug.assign_current_user(@locked_user, @pow_config)
      |> EnsureUserNotLockedPlug.call(opts)

    assert get_flash(conn, :error) == "Sorry, your account is locked."
    assert redirected_to(conn) == Routes.pow_session_path(conn, :new)
  end

  defp init_conn() do
    pow_config = Keyword.put(@pow_config, :plug, Pow.Plug.Session)

    :get
    |> Plug.Test.conn("/")
    |> Plug.Test.init_test_session(%{})
    |> Pow.Plug.put_config(pow_config)
    |> Phoenix.Controller.fetch_flash()
  end
end
