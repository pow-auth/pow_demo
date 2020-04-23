defmodule MyApp.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    pow_user_fields()

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> validate_password_breach()
    |> validate_password_no_context()
    |> validate_password()
    |> validate_password_dictionary()
  end

  defp validate_password_breach(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      case password_breached?(password) do
        true  -> [password: "has appeared in a previous breach"]
        false -> []
      end
    end)
  end

  defp password_breached?(password) do
    case Mix.env() do
      :test -> false
      _any  -> ExPwned.password_breached?(password)
    end
  end

  @app_name "My Demo App"

  defp validate_password_no_context(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      [
        @app_name,
        String.downcase(@app_name),
        Ecto.Changeset.get_field(changeset, :email),
        Ecto.Changeset.get_field(changeset, :username)
      ]
      |> Enum.reject(&is_nil/1)
      |> similar_to_context?(password)
      |> case do
        true  -> [password: "is too similar to username, email or #{@app_name}"]
        false -> []
      end
    end)
  end

  def similar_to_context?(contexts, password) do
    Enum.any?(contexts, &String.jaro_distance(&1, password) > 0.85)
  end
  defp validate_password(changeset) do
    changeset
    |> validate_no_repetitive_characters()
    |> validate_no_sequential_characters()
  end

  defp validate_no_repetitive_characters(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      case repetitive_characters?(password) do
        true  -> [password: "has repetitive characters"]
        false -> []
      end
    end)
  end

  defp repetitive_characters?(password) when is_binary(password) do
    password
    |> String.to_charlist()
    |> repetitive_characters?()
  end
  defp repetitive_characters?([c, c, c | _rest]), do: true
  defp repetitive_characters?([_c | rest]), do: repetitive_characters?(rest)
  defp repetitive_characters?([]), do: false

  defp validate_no_sequential_characters(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      case sequential_characters?(password) do
        true  -> [password: "has sequential characters"]
        false -> []
      end
    end)
  end

  @sequences ["01234567890", "abcdefghijklmnopqrstuvwxyz"]
  @max_sequential_chars 3

  defp sequential_characters?(password) do
    Enum.any?(@sequences, &sequential_characters?(password, &1))
  end

  defp sequential_characters?(password, sequence) do
    max = String.length(sequence) - 1 - @max_sequential_chars

    Enum.any?(0..max, fn x ->
      pattern = String.slice(sequence, x, @max_sequential_chars + 1)

      String.contains?(password, pattern)
    end)
  end

  defp validate_password_dictionary(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      password
      |> String.downcase()
      |> password_in_dictionary?()
      |> case do
        true  -> [password: "is dictionary word"]
        false -> []
      end
    end)
  end

  :my_app
  |> :code.priv_dir()
  |> Path.join("dictionary.txt")
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.each(fn password ->
    defp password_in_dictionary?(unquote(password)), do: true
  end)
  |> Stream.run()

  defp password_in_dictionary?(_password), do: false
end
