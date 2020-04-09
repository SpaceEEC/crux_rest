defmodule Crux.Rest.ApiErrorTest do
  use ExUnit.Case, async: true

  alias Crux.Rest.ApiError
  alias Crux.Rest.Request

  describe "exception/1 - binary" do
    test "raise/2 semantic" do
      assert_raise ApiError, "some message", fn ->
        raise ApiError, "some message"
      end
    end

    test "exception/1 call" do
      assert %ApiError{message: "some message"} == ApiError.exception("some message")
    end
  end

  describe "exception/2" do
    test "mapped error" do
      body =
        Jason.decode!(
          ~s'{"code": 50035, "errors": {"embed": {"fields": {"0": {"name": {"_errors": [{"code": "BASE_TYPE_REQUIRED", "message": "This field is required"}]}}, "1": {"value": {"_errors": [{"code": "BASE_TYPE_REQUIRED", "message": "This field is required"}]}}, "2": {"name": {"_errors": [{"code": "BASE_TYPE_REQUIRED", "message": "This field is required"}]}, "value": {"_errors": [{"code": "BASE_TYPE_REQUIRED", "message": "This field is required"}]}}}}}, "message": "Invalid Form Body"}'
        )

      request = Request.new(:get, "/")

      response = %{
        status_code: 400,
        body: body
      }

      assert %ApiError{
               status_code: 400,
               code: 50035,
               message: """
               Invalid Form Body
               embed.fields[0].name: [BASE_TYPE_REQUIRED] This field is required
               embed.fields[1].value: [BASE_TYPE_REQUIRED] This field is required
               embed.fields[2].name: [BASE_TYPE_REQUIRED] This field is required
               embed.fields[2].value: [BASE_TYPE_REQUIRED] This field is required\
               """,
               path: "/",
               method: :get
             } == ApiError.exception(request, response)
    end

    test "CloudFlare special case" do
      request = Request.new(:get, "/")

      response = %{
        status_code: 400,
        body: "<html>some <b>html</b></html>"
      }

      assert %ApiError{
               status_code: 400,
               code: nil,
               message: "<html>some <b>html</b></html>",
               path: "/",
               method: :get
             } == ApiError.exception(request, response)
    end
  end
end
