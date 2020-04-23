defmodule MyAppWeb.RegistrationControllerTest do
  use MyAppWeb.ConnCase

  alias MyApp.{Users.User, Repo}

  setup %{conn: conn} do
    {:ok, user} =
      Pow.Ecto.Context.create(%{
        email: "test@example.com",
        password: "secret1234",
        password_confirmation: "secret1234"
      }, repo: Repo, user: User)

    {:ok, user} =
      Pow.Ecto.Context.update(user, %{
        email: "updated@example.com",
        current_password: "secret1234"
      }, repo: Repo, user: User)

    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :my_app)

    {:ok, conn: conn, user: user}
  end

  describe "resend_confirmation_email/2" do
    test "sends confirmation email", %{conn: conn} do
      conn = post conn, Routes.registration_path(conn, :resend_confirmation_email)

      assert redirected_to(conn) == Routes.pow_registration_path(conn, :edit)
      assert get_flash(conn, :info) == "E-mail sent, please check your inbox."
    end

    test "with already confirmed email", %{conn: conn, user: user} do
      user = PowEmailConfirmation.Ecto.Context.confirm_email(user, %{}, otp_app: :my_app)

      conn =
        conn
        |> Pow.Plug.assign_current_user(user, otp_app: :my_app)
        |> post(Routes.registration_path(conn, :resend_confirmation_email))

      assert redirected_to(conn) == Routes.pow_registration_path(conn, :edit)
      assert get_flash(conn, :info) == "E-mail has already been confirmed."
    end
  end
end
