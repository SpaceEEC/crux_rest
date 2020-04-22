defmodule Crux.Rest.OptsTest do
  use ExUnit.Case, async: true

  alias Crux.Rest.{Opts, Request}

  @name __MODULE__

  @opts %{name: @name, token: "token"}

  describe "transform/1" do
    test "minimal opts works" do
      assert %Opts{name: @name, token: "token"} === Opts.transform(@opts)
    end

    test "full opts works" do
      assert %Opts{
               name: @name,
               token: "token",
               raw: true,
               version: 8
             } ===
               Opts.transform(%{
                 name: @name,
                 token: "token",
                 raw: true,
                 version: 8
               })
    end

    test "non-binary token raises" do
      assert_raise ArgumentError, ~r/:token/, fn ->
        @opts
        |> Map.put(:token, :error)
        |> Opts.transform()
      end
    end

    test "non-boolean raw raises" do
      assert_raise ArgumentError, ~r/:raw/, fn ->
        @opts
        |> Map.put(:raw, :error)
        |> Opts.transform()
      end
    end

    test "non-atom name raises" do
      assert_raise ArgumentError, ~r/:name/, fn ->
        @opts
        |> Map.put(:name, "name")
        |> Opts.transform()
      end
    end

    test "non-nil/integer version raises" do
      assert_raise ArgumentError, ~r/:version/, fn ->
        @opts
        |> Map.put(:version, "7")
        |> Opts.transform()
      end

      assert_raise ArgumentError, ~r/:version/, fn ->
        @opts
        |> Map.put(:version, :error)
        |> Opts.transform()
      end
    end

    test "non-map raises" do
      assert_raise FunctionClauseError, fn ->
        Opts.transform([])
      end

      assert_raise FunctionClauseError, fn ->
        Opts.transform({"123", Name})
      end
    end
  end

  describe "apply_options/2" do
    setup do
      request =
        :get
        |> Request.new("/")
        |> Request.put_transform(fn _ -> :ok end)

      {:ok, request: request}
    end

    test "with auth", %{request: request} do
      assert request.auth === true

      request = Opts.apply_options(request, Opts.transform(@opts))

      assert Keyword.fetch!(request.headers, :authorization) =~ @opts.token
    end

    test "without auth", %{request: request} do
      request = Request.put_auth(request, false)
      assert request.auth === false

      request = Opts.apply_options(request, Opts.transform(@opts))

      refute Keyword.has_key?(request.headers, :authorization)
    end

    test "raw", %{request: request} do
      opts = Map.put(@opts, :raw, true)
      request = Opts.apply_options(request, Opts.transform(opts))

      assert request.transform === nil
    end

    test "no raw", %{request: request} do
      request = Opts.apply_options(request, Opts.transform(@opts))

      refute request.transform === nil
    end
  end
end
