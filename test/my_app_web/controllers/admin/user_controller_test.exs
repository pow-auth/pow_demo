defmodule MyAppWeb.Admin.UserControllerTest do
  use MyAppWeb.ConnCase

  alias MyApp.{Users, Users.User, Repo}

  describe "lock/2" do
    test "locks user", %{conn: conn} do
      user = user_fixture()

      conn = post conn, Routes.admin_user_path(conn, :lock, user.id)

      assert get_flash(conn, :info) == "User has been locked."
      assert redirected_to(conn) == "/"
    end

    test "with already locked user", %{conn: conn} do
      {:ok, user} = Users.lock(user_fixture())

      conn = post conn, Routes.admin_user_path(conn, :lock, user.id)

      assert get_flash(conn, :error) == "User couldn't be locked."
      assert redirected_to(conn) == "/"
    end
  end

  defp user_fixture() do
    %User{}
    |> User.changeset(%{email: "test@example.com", password: "secret1234", password_confirmation: "secret1234"})
    |> Repo.insert!()
  end
end
