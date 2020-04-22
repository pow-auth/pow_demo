defmodule MyApp.UsersTest do
  use MyApp.DataCase

  alias MyApp.{Repo, Users, Users.User}

  @valid_params %{email: "test@example.com", password: "secret1234", password_confirmation: "secret1234"}

  test "create_admin/2" do
    assert {:ok, user} = Users.create_admin(@valid_params)
    assert user.role == "admin"
  end

  test "set_admin_role/1" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    assert user.role == "user"

    assert {:ok, user} = Users.set_admin_role(user)
    assert user.role == "admin"
  end

  # Uncomment if you added this method to your users context
  test "is_admin?/1" do
    refute Users.is_admin?(nil)

    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    refute Users.is_admin?(user)

    assert {:ok, admin} = Users.create_admin(%{@valid_params | email: "test2@example.com"})
    assert Users.is_admin?(admin)
  end
end
