defmodule MyApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :role, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
