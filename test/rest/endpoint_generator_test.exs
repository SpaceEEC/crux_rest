defmodule Crux.Rest.Endpoints.GeneratorTest do
  use ExUnit.Case, async: true
  doctest Crux.Rest.Endpoints.Generator

  test "simple cases" do
    name = __MODULE__.SimpleCases

    defmodule name do
      use Crux.Rest.Endpoints.Generator

      route("/foo")
      route("/foo/:id")
    end

    assert name.foo() == "/foo"
    assert name.foo(12345) == "/foo/12345"
    assert name.foo(["12345"]) == "/foo/12345"
  end

  test "" do
    name = __MODULE__.AtAndDot

    defmodule name do
      use Crux.Rest.Endpoints.Generator

      route("/foo/@bar")
      route("/foo/@bar.json")
    end

    assert name.foo_bar() == "/foo/@bar"
    assert name.foo_bar_json() == "/foo/@bar.json"
  end

  test "multiple fix parts" do
    name = __MODULE__.MultipleFix

    defmodule name do
      use Crux.Rest.Endpoints.Generator

      route("/:foo/foo/bar/:baz")
    end

    assert name.foo(123) == "/123/foo"
    assert name.foo_bar(123) == "/123/foo/bar"
    assert name.foo_bar(123, 123) == "/123/foo/bar/123"
  end

  test "multiple variable parts" do
    name = __MODULE__.MultipleVariable

    defmodule name do
      use Crux.Rest.Endpoints.Generator

      route("/foo/:foo/:bar/baz")
    end

    assert name.foo() == "/foo"
    assert name.foo(123) == "/foo/123"
    assert name.foo(123, 123) == "/foo/123/123"
    assert name.foo_baz(123, 123) == "/foo/123/123/baz"
  end
end
