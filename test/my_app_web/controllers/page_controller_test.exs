defmodule MyAppWeb.PageControllerTest do
  use MyAppWeb.ConnCase

  @tenant "tenant_a"

  describe "GET /" do
    test "unauthenticated", %{conn: conn} do
      conn = get(conn, "/", subdomain: @tenant)
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
      assert conn.assigns[:current_tenant] == @tenant
    end

    test "authenticated", %{conn: conn} do
      conn = create_auth_user(conn)

      conn = get(conn, "/", subdomain: @tenant)
      assert Pow.Plug.current_user(conn)
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
      assert conn.assigns[:current_tenant] == @tenant
    end
  end

  defp create_auth_user(conn) do
    conn = post(conn, Routes.pow_registration_path(conn, :create, subdomain: @tenant), %{"user" => %{"email" => "test@example.com", "password" => "password", "password_confirmation" => "password"}})

    :get
    |> Plug.Test.conn("/")
    |> Plug.Test.recycle_cookies(conn)
  end
end
