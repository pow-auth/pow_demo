defmodule MyApp.UsersTest do
  use MyApp.DataCase

  alias MyApp.{Repo, Users, Users.User}

  @valid_params %{email: "test@example.com", password: "secret1234", password_confirmation: "secret1234"}

  test "lock/2" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    refute user.locked_at

    assert {:ok, user} = Users.lock(user)
    assert user.locked_at

    assert {:error, changeset} = Users.lock(user)
    assert changeset.errors[:locked_at] == {"already set", []}
  end
end
