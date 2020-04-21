defmodule MyApp.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  alias Ecto.{Changeset, Schema}

  schema "users" do
    field :locked_at, :utc_datetime

    pow_user_fields()

    timestamps()
  end

  @spec lock_changeset(Schema.t() | Changeset.t()) :: Changeset.t()
  def lock_changeset(user_or_changeset) do
    changeset = Changeset.change(user_or_changeset)
    locked_at = DateTime.truncate(DateTime.utc_now(), :second)

    case Changeset.get_field(changeset, :locked_at) do
      nil  -> Changeset.change(changeset, locked_at: locked_at)
      _any -> Changeset.add_error(changeset, :locked_at, "already set")
    end
  end
end
