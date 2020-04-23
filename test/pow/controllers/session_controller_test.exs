defmodule Pow.Controllers.SessionControllerTest do
  use MyAppWeb.ConnCase

  alias MyApp.{Repo, Users.User}

  describe "POST /session" do
    @weak_password "123456"
    @strong_password "horse battery staple"

    test "with insecure password", %{conn: conn} do
      user = user_fixture(@weak_password)
      conn = post(conn, Routes.pow_session_path(conn, :create), %{"user" => %{"email" => user.email, password: @weak_password}})

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      refute Pow.Plug.current_user(conn)
      assert get_flash(conn, :error) == "You have to reset your password because it has sequential characters"
    end

    test "with strong password", %{conn: conn} do
      user = user_fixture(@strong_password)
      conn = post(conn, Routes.pow_session_path(conn, :create), %{"user" => %{"email" => user.email, password: @strong_password}})

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert Pow.Plug.current_user(conn)
    end
  end

  defp user_fixture(password) do
    Repo.insert!(%User{
      email: "test@example.com",
      password_hash: Pow.Ecto.Schema.Password.pbkdf2_hash(password)
    })
  end
end
