defmodule Crux.Rest.RateLimiterTest do
  use ExUnit.Case

  import Mox

  alias Crux.Rest.RateLimiter.Default, as: RateLimiter
  alias Crux.Rest.RateLimiter.Default.Handler.Supervisor, as: HandlerSupervisor
  alias Crux.Rest.RateLimiter.Default.Global
  alias Crux.Rest.Request
  alias Crux.Rest.Endpoints

  @name RateLimiterTest

  @opts %{
    name: @name,
    token: "some_cool_token"
  }

  # To make mox global
  setup :set_mox_from_context
  # Ensure mocked functions were actually called
  setup :verify_on_exit!

  setup do
    start_supervised({RateLimiter, @opts})

    :ok
  end

  def response() do
    response(%{})
  end

  def response(data) do
    data = Map.new(data)

    status = Map.get(data, :status, 200)
    body = Map.get(data, :body, "some boring body")

    headers =
      Enum.reduce(data, %{}, fn
        {:limit, limit}, acc ->
          Map.put(acc, "x-ratelimit-limit", to_string(limit))

        {:remaining, remaining}, acc ->
          Map.put(acc, "x-ratelimit-remaining", to_string(remaining))

        {:reset, reset_after}, acc ->
          reset_after_s = reset_after / 1000

          acc
          |> Map.put(
            "x-ratelimit-reset",
            to_string(:os.system_time(:millisecond) + reset_after_s)
          )
          |> Map.put("x-ratelimit-reset-after", to_string(reset_after_s))
          |> Map.put("retry-after", to_string(reset_after))

        {:global, true}, acc ->
          Map.put(acc, "x-ratelimit-global", "true")

        {:bucket_hash, bucket_hash}, acc ->
          Map.put(acc, "x-ratelimit-bucket", bucket_hash)

        _header, acc ->
          acc
      end)
      |> Map.merge(data[:headers] || %{}, fn _key, value1, _value2 -> value1 end)
      |> Map.to_list()

    {:ok,
     %{
       status_code: status,
       body: body,
       headers: headers
     }}
  end

  def request_one() do
    Request.new(
      :get,
      Endpoints.channels_messages(559_412_396_586_696_706)
    )
  end

  def request_two() do
    Request.new(
      :get,
      Endpoints.channels_messages(381_886_868_708_655_104)
    )
  end

  # https://stackoverflow.com/a/28746505/10602948
  defp assert_throttled(timeout, fun) do
    task = Task.async(fun)
    ref = Process.monitor(task.pid)
    refute_receive {:DOWN, ^ref, :process, _, :normal}, timeout
    Task.await(task)
  end

  describe "no rate limit" do
    test "no headers, once works" do
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      assert success_response == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
    end

    test "no headers - twice works" do
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, 2, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      assert success_response == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
      assert success_response == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
    end

    test "headers - twice works" do
      response_one = response(limit: 10, remaining: 9, reset: 5000)
      response_two = response(limit: 10, remaining: 8, reset: 4800)

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response_one
      end)
      |> expect(:request, fn @opts, _request ->
        response_two
      end)

      request = request_one()

      assert response_one == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
      assert response_two == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
    end
  end

  describe "rate limits - local" do
    test "preemptive throttling" do
      success_response = response()
      exhaust_response = response(remaining: 0, limit: 1, reset: 250)

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        exhaust_response
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      # Make initial request exhausting the bucket
      assert exhaust_response = RateLimiter.request(@name, request, Crux.Rest.HTTPMock)

      # Make another request, but it is being delayed by the specified 250ms
      response =
        assert_throttled(200, fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      assert success_response == response
    end

    test "simple - local rate limit " do
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response(status: 429, limit: 1, remaining: 0, reset: 250)
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      response =
        assert_throttled(200, fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      assert success_response == response
    end

    test "simple - global rate limit " do
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response(global: true, status: 429, limit: 1, remaining: 0, reset: 250)
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      task =
        Task.async(fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      ref = Process.monitor(task.pid)

      # Ensure that the task propagated the global rate limit
      Process.sleep(100)

      assert Global.get_retry_after(@name) > 0

      refute_receive {:DOWN, ^ref, :process, _, :normal}, 100
      response = Task.await(task)

      assert success_response == response
    end
  end

  describe "rate limits - bucket" do
    test "preemptive throttling" do
      bucket_hash = "some_bucket_hash"
      init_response = response(limit: 3, remaining: 1, reset: 450, bucket_hash: bucket_hash)
      exhaust_response = response(limit: 3, remaining: 0, reset: 250, bucket_hash: bucket_hash)
      success_response = response(limit: 3, remaining: 2, reset: 450, bucket_hash: bucket_hash)

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        init_response
      end)
      |> expect(:request, fn @opts, _request ->
        exhaust_response
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      # Make initial request specifying the bucket
      assert init_response = RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
      # Make second request exhausting the bucket
      assert exhaust_response = RateLimiter.request(@name, request, Crux.Rest.HTTPMock)

      # Make another request, but it is being delayed by the specified 250ms
      response =
        assert_throttled(200, fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      assert success_response == response
    end

    test "simple - local rate limit " do
      bucket_hash = "some_bucket_hash"
      init_response = response(limit: 3, remaining: 1, reset: 450, bucket_hash: bucket_hash)
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        init_response
      end)
      |> expect(:request, fn @opts, _request ->
        response(status: 429, limit: 1, remaining: 0, reset: 250)
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      # Make initial request specifying the bucket
      assert init_response = RateLimiter.request(@name, request, Crux.Rest.HTTPMock)

      response =
        assert_throttled(200, fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      assert success_response == response
    end

    test "simple - global rate limit " do
      bucket_hash = "some_bucket_hash"
      init_response = response(limit: 3, remaining: 1, reset: 450, bucket_hash: bucket_hash)
      success_response = response()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        init_response
      end)
      |> expect(:request, fn @opts, _request ->
        response(global: true, status: 429, limit: 1, remaining: 0, reset: 250)
      end)
      |> expect(:request, fn @opts, _request ->
        success_response
      end)

      request = request_one()

      # Make initial request specifying the bucket
      assert init_response = RateLimiter.request(@name, request, Crux.Rest.HTTPMock)

      task =
        Task.async(fn ->
          RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
        end)

      ref = Process.monitor(task.pid)

      # Ensure that the task propagated the global rate limit
      Process.sleep(100)

      assert Global.get_retry_after(@name) > 0

      refute_receive {:DOWN, ^ref, :process, _, :normal}, 100
      response = Task.await(task)

      assert success_response == response
    end
  end

  describe "lifecycle" do
    test "first request does not start a bucket handler" do
      response = response(limit: 10, remaining: 9, reset: 5000, bucket_hash: "cool_bucket_hash")
      request = request_one()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response
      end)

      assert response ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )
    end

    test "second request does start a bucket handler" do
      bucket_hash = "cool_bucket_hash"
      response_one = response(limit: 10, remaining: 9, reset: 5000, bucket_hash: bucket_hash)
      response_two = response(limit: 10, remaining: 8, reset: 4800, bucket_hash: bucket_hash)
      request = request_one()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response_one
      end)
      |> expect(:request, fn @opts, _request ->
        response_two
      end)

      assert response_one ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )

      parent = self()

      bucket_hash_with_major = "#{request.major}:#{bucket_hash}"

      patched_request =
        RateLimiter.new(request, Crux.Rest.HTTPMock)
        |> Map.update!(:dispatch, fn orig_dispatch ->
          fn @name = name, %{bucket_hash: ^bucket_hash_with_major} = message ->
            send(parent, :called)

            orig_dispatch.(name, message)
          end
        end)

      assert response_two == HandlerSupervisor.dispatch(@name, patched_request)

      assert_received :called
    end

    test "different routes, same bucket hash, same major -> same handlers" do
      bucket_hash = "cool_bucket_hash"
      response_one = response(limit: 10, remaining: 9, reset: 5000, bucket_hash: bucket_hash)
      response_two = response(limit: 10, remaining: 8, reset: 4800, bucket_hash: bucket_hash)
      response_three = response(limit: 10, remaining: 7, reset: 4600, bucket_hash: bucket_hash)
      response_four = response(limit: 10, remaining: 6, reset: 4400, bucket_hash: bucket_hash)
      request_one = Request.new(:get, Endpoints.gateway_bot())
      request_two = Request.new(:get, Endpoints.gateway())

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response_one
      end)
      |> expect(:request, fn @opts, _request ->
        response_two
      end)
      |> expect(:request, fn @opts, _request ->
        response_three
      end)
      |> expect(:request, fn @opts, _request ->
        response_four
      end)

      assert response_one ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request_one, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )

      assert response_two ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request_two, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )

      parent = self()

      patched_request =
        RateLimiter.new(request_one, Crux.Rest.HTTPMock)
        |> Map.update!(:dispatch, fn orig_dispatch ->
          fn @name = name, %{bucket_hash: ^bucket_hash} = message ->
            send(parent, :called)

            orig_dispatch.(name, message)
          end
        end)

      assert response_three == HandlerSupervisor.dispatch(@name, patched_request)

      assert_received :called

      patched_request =
        RateLimiter.new(request_two, Crux.Rest.HTTPMock)
        |> Map.update!(:dispatch, fn orig_dispatch ->
          fn @name = name, %{bucket_hash: ^bucket_hash} = message ->
            send(parent, :called2)

            orig_dispatch.(name, message)
          end
        end)

      assert response_four == HandlerSupervisor.dispatch(@name, patched_request)

      assert_received :called2
    end

    test "different routes, same bucket hash, different major -> different handlers" do
      bucket_hash = "cool_bucket_hash"
      response_one = response(limit: 10, remaining: 9, reset: 5000, bucket_hash: bucket_hash)
      response_two = response(limit: 10, remaining: 8, reset: 4800, bucket_hash: bucket_hash)
      response_three = response(limit: 10, remaining: 7, reset: 4600, bucket_hash: bucket_hash)
      response_four = response(limit: 10, remaining: 6, reset: 4400, bucket_hash: bucket_hash)
      request_one = request_one()
      request_two = request_two()

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        response_one
      end)
      |> expect(:request, fn @opts, _request ->
        response_two
      end)
      |> expect(:request, fn @opts, _request ->
        response_three
      end)
      |> expect(:request, fn @opts, _request ->
        response_four
      end)

      assert response_one ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request_one, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )

      assert response_two ==
               HandlerSupervisor.dispatch(
                 @name,
                 RateLimiter.new(request_two, Crux.Rest.HTTPMock, fn _, _ ->
                   raise "not to be called!"
                 end)
               )

      parent = self()

      bucket_hash_one = "#{request_one.major}:#{bucket_hash}"

      patched_request =
        RateLimiter.new(request_one, Crux.Rest.HTTPMock)
        |> Map.update!(:dispatch, fn orig_dispatch ->
          fn @name = name, %{bucket_hash: ^bucket_hash_one} = message ->
            send(parent, :called)

            orig_dispatch.(name, message)
          end
        end)

      assert response_three == HandlerSupervisor.dispatch(@name, patched_request)

      assert_received :called

      bucket_hash_two = "#{request_two.major}:#{bucket_hash}"

      patched_request =
        RateLimiter.new(request_two, Crux.Rest.HTTPMock)
        |> Map.update!(:dispatch, fn orig_dispatch ->
          fn @name = name, %{bucket_hash: ^bucket_hash_two} = message ->
            send(parent, :called2)

            orig_dispatch.(name, message)
          end
        end)

      assert response_four == HandlerSupervisor.dispatch(@name, patched_request)

      assert_received :called2
    end
  end

  describe "error handling" do
    test "request handler passes error back to as-is" do
      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        {:error, :real_badarg}
      end)

      request = request_one()
      assert {:error, :real_badarg} == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
    end

    test "bucket handler passes error back to as-is" do
      bucket_hash = "some_bucket_hash"
      init_response = response(bucket_hash: bucket_hash)

      Crux.Rest.HTTPMock
      |> expect(:request, fn @opts, _request ->
        init_response
      end)
      |> expect(:request, fn @opts, _request ->
        {:error, :real_badarg}
      end)

      request = request_one()

      # Make initial request specifying the bucket
      assert init_response == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)

      assert {:error, :real_badarg} == RateLimiter.request(@name, request, Crux.Rest.HTTPMock)
    end
  end
end
