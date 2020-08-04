defmodule MyAppWeb.Pow.CachexCacheTest do
  use ExUnit.Case
  doctest MyAppWeb.Pow.CachexCache

  alias MyAppWeb.Pow.CachexCache

  @default_config [namespace: "test", ttl: :timer.hours(1)]

  test "can put, get and delete records" do
    assert CachexCache.get(@default_config, "key") == :not_found

    CachexCache.put(@default_config, {"key", "value"})
    :timer.sleep(100)
    assert CachexCache.get(@default_config, "key") == "value"

    CachexCache.delete(@default_config, "key")
    :timer.sleep(100)
    assert CachexCache.get(@default_config, "key") == :not_found
  end

  test "can put multiple records at once" do
    CachexCache.put(@default_config, [{"key1", "1"}, {"key2", "2"}])
    :timer.sleep(100)
    assert CachexCache.get(@default_config, "key1") == "1"
    assert CachexCache.get(@default_config, "key2") == "2"
  end

  test "can match fetch all" do
    assert CachexCache.all(@default_config, :_) == []

    for number <- 1..11, do: CachexCache.put(@default_config, {"key#{number}", "value"})
    :timer.sleep(100)
    items = CachexCache.all(@default_config, :_)

    assert Enum.find(items, fn {key, "value"} -> key == "key1" end)
    assert Enum.find(items, fn {key, "value"} -> key == "key2" end)
    assert length(items) == 11

    CachexCache.put(@default_config, {["namespace", "key"], "value"})
    :timer.sleep(100)

    assert CachexCache.all(@default_config, ["namespace", :_]) ==  [{["namespace", "key"], "value"}]
  end

  test "records auto purge" do
    config = Keyword.put(@default_config, :ttl, 100)

    CachexCache.put(config, {"key", "value"})
    CachexCache.put(config, [{"key1", "1"}, {"key2", "2"}])
    :timer.sleep(50)
    assert CachexCache.get(config, "key") == "value"
    assert CachexCache.get(config, "key1") == "1"
    assert CachexCache.get(config, "key2") == "2"
    :timer.sleep(100)
    assert CachexCache.get(config, "key") == :not_found
    assert CachexCache.get(config, "key1") == :not_found
    assert CachexCache.get(config, "key2") == :not_found
  end
end
