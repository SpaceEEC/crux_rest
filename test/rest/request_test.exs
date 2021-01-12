defmodule Crux.Rest.RequestTests do
  use ExUnit.Case, async: true

  alias Crux.Rest.Endpoints
  alias Crux.Rest.Request

  setup do
    {:ok, request: Request.new(:get, "/")}
  end

  describe "get_route/1" do
    test "handles regular routes correctly" do
      assert "/gateway/bot" == Request.get_route(Endpoints.gateway_bot())

      assert "/guilds/516569101267894284/members/:id/roles/:id" ==
               Request.get_route(
                 Endpoints.guilds_members_roles(
                   516_569_101_267_894_284,
                   560_524_012_627_820_547,
                   559_412_083_922_305_034
                 )
               )
    end

    test "handles reaction routes special behavior" do
      assert "/channels/559412396586696706/messages/:id/reactions/*" ==
               Request.get_route(
                 Endpoints.channels_messages_reactions(
                   559_412_396_586_696_706,
                   696_786_024_621_408_337,
                   "QuestionMark:367379627984945153"
                 )
               )
    end

    test "handles webhook routes correctly" do
      assert "/webhooks/559412396586696706/*" ==
               Request.get_route(Endpoints.webhooks(559_412_396_586_696_706))

      assert "/webhooks/559412396586696706/*" ==
               Request.get_route(Endpoints.webhooks_messages(559_412_396_586_696_706, nil))

      assert "/webhooks/559412396586696706/*" ==
               Request.get_route(
                 Endpoints.webhooks_messages(559_412_396_586_696_706, "some token")
               )
    end
  end

  describe "get_major/1" do
    test "handles path with major parameter" do
      assert "559412396586696706" ==
               Request.get_major(Endpoints.channels_messages(559_412_396_586_696_706))

      assert "516569101267894284" == Request.get_major(Endpoints.guilds(516_569_101_267_894_284))
    end

    test "handles webhook edge cases correctly" do
      assert "550715604512931840" ==
               Request.get_major(Endpoints.webhooks(550_715_604_512_931_840))

      assert "550715604512931840" ==
               Request.get_major(Endpoints.webhooks_messages(550_715_604_512_931_840, nil))

      assert "550715604512931840" ==
               Request.get_major(Endpoints.webhooks_github(550_715_604_512_931_840, nil))

      assert "some token" ==
               Request.get_major(Endpoints.webhooks(550_715_604_512_931_840, "some token"))

      assert "some token" ==
               Request.get_major(
                 Endpoints.webhooks_messages(550_715_604_512_931_840, "some token")
               )

      assert "some token" ==
               Request.get_major(Endpoints.webhooks_github(550_715_604_512_931_840, "some token"))
    end

    test "handles route without major parameter" do
      assert nil === Request.get_major(Endpoints.gateway_bot())
    end
  end

  describe "new/3" do
    test "adds route" do
      endpoint =
        Endpoints.channels_messages_reactions(
          559_412_396_586_696_706,
          696_786_024_621_408_337,
          "QuestionMark:367379627984945153"
        )

      request = Request.new(:get, endpoint)

      assert %Request{
               method: :get,
               path: endpoint,
               major: Request.get_major(endpoint),
               route: Request.get_route(endpoint),
               data: ""
             } == request
    end

    test "fails with invalid method" do
      assert_raise FunctionClauseError, fn ->
        Request.new(:path, "/gateway")
      end
    end

    test "fails with invalid path" do
      assert_raise FunctionClauseError, fn ->
        Request.new(:get, :path)
      end
    end
  end

  describe "put_headers/2" do
    test "works", %{request: request} do
      assert is_list(request.headers)
      refute Keyword.has_key?(request.headers, :foo)
      refute Keyword.has_key?(request.headers, :bar)

      %{headers: headers} = Request.put_headers(request, foo: "bar", bar: "baz")

      assert Keyword.fetch!(headers, :foo) == "bar"
      assert Keyword.fetch!(headers, :bar) == "baz"
    end

    test "fails with non-list", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_headers(request, %{foo: "bar", bar: "baz"})
      end
    end

    test "fails with non-keyword-list", %{request: request} do
      assert_raise ArgumentError, fn ->
        Request.put_headers(request, [{"foo", "bar"}, {"bar", "baz"}])
      end
    end
  end

  describe "put_params/2" do
    test "works", %{request: request} do
      assert nil == request.params

      %{params: params} = Request.put_params(request, foo: "bar", bar: "baz")

      assert is_list(params)
      assert Keyword.fetch!(params, :foo) == "bar"
      assert Keyword.fetch!(params, :bar) == "baz"
    end

    test "fails with non-list", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_params(request, %{})
      end
    end
  end

  describe "put_transform/2" do
    test "structs", %{request: request} do
      assert nil == request.transform

      %{transform: transform} = Request.put_transform(request, Crux.Structs.Message)

      assert transform == Crux.Structs.Message
    end

    test "custom function", %{request: request} do
      fun = fn data -> String.to_integer(data["count"]) end

      %{transform: transform} = Request.put_transform(request, fun)

      assert transform == fun
    end

    test "fails with invalid function arity", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_transform(request, fn _, _ -> %{} end)
      end
    end
  end

  describe "put_reason/2" do
    test "nonempty reason", %{request: request} do
      refute Keyword.has_key?(request.headers, :"x-audit-log-reason")

      %{headers: headers} = Request.put_reason(request, "some reason!")
      assert Keyword.fetch!(headers, :"x-audit-log-reason") == URI.encode("some reason!")
    end

    test "effectively empty reason", %{request: request} do
      refute Keyword.has_key?(request.headers, :"x-audit-log-reason")

      %{headers: headers} = Request.put_reason(request, "      \t   ")
      refute Keyword.has_key?(headers, :"x-audit-log-reason")
    end

    test "empty reason", %{request: request} do
      refute Keyword.has_key?(request.headers, :"x-audit-log-reason")

      %{headers: headers} = Request.put_reason(request, "")
      refute Keyword.has_key?(headers, :"x-audit-log-reason")
    end

    test "nil reason", %{request: request} do
      refute Keyword.has_key?(request.headers, :"x-audit-log-reason")

      %{headers: headers} = Request.put_reason(request, nil)
      refute Keyword.has_key?(headers, :"x-audit-log-reason")
    end

    test "invalid reason raises", %{request: request} do
      refute Keyword.has_key?(request.headers, :"x-audit-log-reason")

      assert_raise FunctionClauseError, fn ->
        Request.put_reason(request, %{})
      end
    end
  end

  describe "put_token/2" do
    test "works", %{request: request} do
      refute Keyword.has_key?(request.headers, :authorization)

      %{headers: headers} = Request.put_token(request, "Cool_Valid_Token")

      assert Keyword.fetch!(headers, :authorization) == "Bot Cool_Valid_Token"
    end

    test "invalid token fails", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_token(request, %{})
      end
    end
  end

  describe "put_version/2" do
    test "integer", %{request: request} do
      assert nil == request.version

      %{version: version} = Request.put_version(request, 7)

      assert version == 7
    end

    test "nil", %{request: request} do
      assert nil == request.version

      %{version: version} = Request.put_version(request, nil)

      assert nil == version
    end

    test "invalid values fail", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_version(request, %{})
      end
    end
  end

  describe "put_auth/2" do
    test "false", %{request: request} do
      assert request.auth == true

      %{auth: auth} = Request.put_auth(request, false)

      assert auth == false
    end

    test "true", %{request: request} do
      assert request.auth == true

      %{auth: auth} = Request.put_auth(request, true)

      assert auth == true
    end

    test "invalid values fail", %{request: request} do
      assert_raise FunctionClauseError, fn ->
        Request.put_auth(request, 1)
      end
    end
  end

  describe "transform/2" do
    test "struct invokes Crux.Structs @behaviour", %{request: request} do
      request = Request.put_transform(request, Crux.Structs.User)

      data = %{
        "id" => "218348062828003328",
        "avatar" => "646a356e237350bf8b8dfde15667dfc4",
        "username" => "space",
        "discriminator" => "0001"
      }

      user = Request.transform(request, data)

      assert Crux.Structs.create(data, Crux.Structs.User) == user
    end

    test "function modifies the value", %{request: request} do
      request = Request.put_transform(request, fn data -> {:ok, data} end)

      assert {:ok, nil} == Request.transform(request, nil)
    end

    test "nil is a noop", %{request: request} do
      request = Request.put_transform(request, nil)

      assert 123_456 == Request.transform(request, 123_456)
    end
  end
end
