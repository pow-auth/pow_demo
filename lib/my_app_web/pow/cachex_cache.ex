defmodule MyAppWeb.Pow.CachexCache do
  @behaviour Pow.Store.Backend.Base

  alias Pow.Config

  @cachex_tab __MODULE__

  @impl true
  def put(config, record_or_records) do
    records =
      record_or_records
      |> List.wrap()
      |> Enum.map(fn {key, value} ->
        {wrap_namespace(config, key), value}
      end)

    {:ok, true} = Cachex.put_many(@cachex_tab, records, ttl: Config.get(config, :ttl))

    :ok
  end

  @impl true
  def delete(config, key) do
    key = wrap_namespace(config, key)

    {:ok, _value} = Cachex.del(@cachex_tab, key)

    :ok
  end

  @impl true
  def get(config, key) do
    key = wrap_namespace(config, key)

    case Cachex.get(@cachex_tab, key) do
      {:ok, nil}   -> :not_found
      {:ok, value} -> value
    end
  end

  @impl true
  def all(config, key_match) do
    query =
      [{
        {:_, wrap_namespace(config, key_match), :"$2", :"$3", :"$4"},
        [Cachex.Query.unexpired_clause()],
        [ :"$_" ]
      }]

    @cachex_tab
    |> Cachex.stream!(query)
    |> Enum.map(fn {_, key, _, _, value} -> {unwrap_namespace(key), value} end)
  end

  defp wrap_namespace(config, key) do
    namespace = Config.get(config, :namespace, "cache")

    [namespace | List.wrap(key)]
  end

  defp unwrap_namespace([_namespace, key]), do: key
  defp unwrap_namespace([_namespace | key]), do: key
end
