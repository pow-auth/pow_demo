defmodule MyApp.Users.UserTest do
  use MyApp.DataCase

  alias MyApp.Users.User

  test "changeset/2 sets default role" do
    user =
      %User{}
      |> User.changeset(%{})
      |> Ecto.Changeset.apply_changes()

    assert user.role == "user"
  end

  test "changeset_role/2" do
    changeset = User.changeset_role(%User{}, %{role: "invalid"})
    assert changeset.errors[:role] == {"is invalid", [validation: :inclusion, enum: ["user", "admin"]]}

    changeset = User.changeset_role(%User{}, %{role: "admin"})
    refute changeset.errors[:role]
  end
end
