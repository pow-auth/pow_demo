defmodule MyAppWeb.ResetPasswordControllerTest do
  use MyAppWeb.ConnCase

  alias MyApp.{Users, Users.User, Repo}
  alias PowResetPassword.Store.ResetTokenCache

  describe "create/2" do
    @valid_params %{"user" => %{"email" => "test@example.com"}}

    test "with user", %{conn: conn} do
      user = user_fixture()

      conn = post conn, Routes.reset_password_path(conn, :create, @valid_params)

      assert get_flash(conn, :info)
      assert redirected_to(conn) == Routes.pow_session_path(conn, :new)

      assert count_reset_password_tokens_for_user(conn, user) == 1
    end

    test "with locked user", %{conn: conn} do
      {:ok, user} = Users.lock(user_fixture())

      conn = post conn, Routes.reset_password_path(conn, :create, @valid_params)

      assert get_flash(conn, :info)
      assert redirected_to(conn) == Routes.pow_session_path(conn, :new)

      assert count_reset_password_tokens_for_user(conn, user) == 0
    end
  end

  defp user_fixture() do
    %User{}
    |> User.changeset(%{email: "test@example.com", password: "secret1234", password_confirmation: "secret1234"})
    |> Repo.insert!()
  end

  defp count_reset_password_tokens_for_user(conn, user) do
    backend =
      conn
      |> Pow.Plug.fetch_config()
      |> Pow.Config.get(:cache_store_backend, Pow.Store.Backend.EtsCache)

    :timer.sleep(100)

    [backend: backend]
    |> ResetTokenCache.all([:_])
    |> Enum.filter(fn {_key, %{id: id}} -> id == user.id end)
    |> length()
  end
end
