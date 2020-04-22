defmodule Crux.Rest.RateLimiter.Default.GlobalTest do
  use ExUnit.Case, async: true

  alias Crux.Rest.RateLimiter.Default.Global

  @name __MODULE__

  @opts %{
    name: @name
  }

  setup do
    start_supervised!({Global, @opts})

    :ok
  end

  test "get_retry_after/1 returns initially 0" do
    assert 0 == Global.get_retry_after(@name)
  end

  test "set_retry_after/2 returns value" do
    retry_after = 10000

    assert retry_after == Global.set_retry_after(@name, retry_after)
  end

  test "get_retry_after/1 returns non 0 after set_retry_after/2 runs" do
    retry_after = 10000

    Global.set_retry_after(@name, retry_after)

    assert Global.get_retry_after(@name) > 0
  end

  test "get_retry_after/1 returns 0 after the retry_after elapsed" do
    # Cheat by setting a negative value
    retry_after = -10000

    Global.set_retry_after(@name, retry_after)

    assert 0 == Global.get_retry_after(@name)
  end
end
