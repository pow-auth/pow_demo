defmodule MyAppWeb.Pow.TriplexSessionPlugTest do
  use MyAppWeb.ConnCase

  alias MyAppWeb.Pow.TriplexSessionPlug

  @pow_config [otp_app: :my_app]
  @tenant_a "tenant_a"
  @tenant_b "tenant_b"
  @valid_user_params %{
    "email" => "test@example.com",
    "password" => "password",
    "password_confirmation" => "password"
  }

  setup do
    {:ok, conn: init_conn()}
  end

  test "handles Triplex tenants", %{conn: conn} do
    opts = TriplexSessionPlug.init(@pow_config)
    {:ok, _user, _conn} =
      conn
      |> set_triplex_tenant(@tenant_a)
      |> TriplexSessionPlug.call(opts)
      |> Pow.Plug.create_user(@valid_user_params)

    {:error, _conn} =
      conn
      |> set_triplex_tenant(@tenant_b)
      |> TriplexSessionPlug.call(opts)
      |> Pow.Plug.authenticate_user(@valid_user_params)

    {:ok, _conn} =
      conn
      |> set_triplex_tenant(@tenant_a)
      |> TriplexSessionPlug.call(opts)
      |> Pow.Plug.authenticate_user(@valid_user_params)
  end

  defp init_conn() do
    :get
    |> Plug.Test.conn("/")
    |> Plug.Test.init_test_session(%{})
    |> Phoenix.Controller.fetch_flash()
  end

  defp set_triplex_tenant(conn, tenant) do
    conn = %{conn | params: %{"subdomain" => tenant}}
    opts = Triplex.ParamPlug.init(param: :subdomain)

    Triplex.ParamPlug.call(conn, opts)
  end
end
