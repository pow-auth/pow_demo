defmodule MyApp.Users.UserTest do
  use MyApp.DataCase

  alias MyApp.Users.User

  test "changeset/2 validates context-specific words" do
    for invalid <- ["my demo app", "mydemo_app", "mydemoapp1"] do
      changeset = User.changeset(%User{}, %{"username" => "john.doe", "password" => invalid})
      assert changeset.errors[:password] == {"is too similar to username, email or My Demo App", []}
    end

    # The below is for email user id
    changeset = User.changeset(%User{}, %{"email" => "john.doe@example.com", "password" => "password12"})
    refute changeset.errors[:password]

    for invalid <- ["john.doe@example.com", "johndoeexamplecom"] do
      changeset = User.changeset(%User{}, %{"email" => "john.doe@example.com", "password" => invalid})
      assert changeset.errors[:password] == {"is too similar to username, email or My Demo App", []}
    end

    # The below is for username user id
    # changeset = User.changeset(%User{}, %{"username" => "john.doe", "password" => "password12"})
    # refute changeset.errors[:password]

    # for invalid <- ["john.doe00", "johndoe", "johndoe1"] do
    #   changeset = User.changeset(%User{}, %{"username" => "john.doe", "password" => invalid})
    #   assert changeset.errors[:password] == {"is too similar to username, email or My Demo App", []}
    # end
  end

  test "changeset/2 validates repetitive and sequential password" do
    changeset = User.changeset(%User{}, %{"password" => "secret1222"})
    assert changeset.errors[:password] == {"has repetitive characters", []}

    changeset = User.changeset(%User{}, %{"password" => "secret1223"})
    refute changeset.errors[:password]

    changeset = User.changeset(%User{}, %{"password" => "secret1234"})
    assert changeset.errors[:password] == {"has sequential characters", []}

    changeset = User.changeset(%User{}, %{"password" => "secret1235"})
    refute changeset.errors[:password]

    changeset = User.changeset(%User{}, %{"password" => "secretefgh"})
    assert changeset.errors[:password] == {"has sequential characters", []}

    changeset = User.changeset(%User{}, %{"password" => "secretafgh"})
    refute changeset.errors[:password]
  end

  @dictionary_word "anteater"

  test "changeset/2 validates dictionary word" do
    changeset = User.changeset(%User{}, %{"password" => @dictionary_word})
    assert changeset.errors[:password] == {"is dictionary word", []}

    changeset = User.changeset(%User{}, %{"password" => "#{@dictionary_word} battery staple"})
    refute changeset.errors[:password]
  end
end
