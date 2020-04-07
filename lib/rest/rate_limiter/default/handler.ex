defmodule Crux.Rest.RateLimiter.Default.Handler do
  @moduledoc false
  @moduledoc since: "0.3.0"

  use GenServer

  alias Crux.Rest.Opts
  alias Crux.Rest.RateLimiter.Default, as: RateLimiter
  alias Crux.Rest.RateLimiter.Default.Global

  @bucket :bucket
  def bucket(), do: @bucket
  @request :request
  def request(), do: @request

  @timeout 10000

  defstruct [
    :name,
    :type,
    :identifier,
    :bucket_hash,
    rl_info: RateLimiter.to_info(%{})
  ]

  ###
  # Client API
  ###

  def child_spec(tuple) do
    %{
      id: tuple,
      start: {__MODULE__, :start_link, [tuple]},
      restart: :temporary
    }
  end

  @spec start_link(Opts.t(), term()) :: GenServer.on_start()
  def start_link(%{name: name} = opts, tuple) do
    registry = Opts.registry(name)

    name = {:via, Registry, {registry, tuple}}
    GenServer.start_link(__MODULE__, {opts, tuple}, name: name)
  end

  def dispatch(pid, message) do
    GenServer.call(pid, message, :infinity)
  end

  ###
  # Server API
  ###

  @impl GenServer
  def init({opts, {type, identifier}}) do
    state = %__MODULE__{
      name: opts.name,
      type: type,
      identifier: identifier
    }

    require Logger

    Logger.metadata(
      name: opts.name,
      type: type,
      identifier: identifier
    )

    debug("Started handler.", state)

    {:ok, state, @timeout}
  end

  # Stops the genserver once it's inactive for @timeout ms.
  @impl GenServer
  def handle_info(:timeout, state) do
    debug("Idle. Stopping.", state)

    {:stop, :normal, state}
  end

  # Ensures that the genserver sleeps long enough once a rate limit limit was exhausted.
  @impl GenServer
  def handle_continue(wait_time, state) do
    debug("Exhausted request limit, sleeping for #{wait_time}ms.", state)

    Process.sleep(wait_time)

    {:noreply, state, @timeout}
  end

  # Request handler does not know its bucket hash, makes request itself.
  @impl GenServer
  def handle_call(message, _from, %{type: @request, bucket_hash: nil} = state) do
    debug("Bucket hash unknown, making request locally.", state)

    case do_request(message, state) do
      {:error, _error} = tuple ->
        {:reply, tuple, state, @timeout}

      {:ok, response, state} ->
        # Set the timeout to at least the reset_after value
        reset_after = Map.get(state.rl_info, :reset_after, 0)
        timeout = max(reset_after, @timeout)

        {:reply, response, state, timeout}

      {:ok, response, state, reset_after} ->
        {:reply, response, state, {:continue, reset_after}}
    end
  end

  # Request handler does know its bucket hash, dispatches request to relevant bucket hash handler.
  def handle_call(
        %{dispatch: dispatch} = message,
        _from,
        %{name: name, type: @request, bucket_hash: bucket_hash} = state
      ) do
    debug("Bucket hash known, dispatching to bucket handler.", state)

    message = Map.put(message, :bucket_hash, bucket_hash)

    {_, _} = response = dispatch.(name, message)

    {:reply, response, state, @timeout}
  end

  # Bucket handler always makes the request itself.
  def handle_call(message, _from, %{type: @bucket} = state) do
    debug("Bucket handler, making request.", state)

    case do_request(message, state) do
      {:error, _error} = tuple ->
        {:reply, tuple, state, @timeout}

      {:ok, response, state} ->
        {:reply, response, state, @timeout}

      {:ok, response, state, reset_after} ->
        {:reply, response, state, {:continue, reset_after}}
    end
  end

  defp do_request(%{http: http, request: request} = message, %{name: name} = state) do
    # If globally rate limited, pause...
    wait_global(state)

    debug("Actually making request.", state)

    case http.request(name, request) do
      {:error, error} = tuple ->
        warn("An error occured: #{inspect(error)}", state)

        tuple

      {:ok, response} = tuple ->
        nil
        rl_headers = RateLimiter.get_rate_limit_values(response.headers)

        log_response(response, rl_headers, state)

        if response.status_code == 429 do
          wait_time =
            case rl_headers do
              %{global: true, retry_after: retry_after} ->
                warn("Globally rate limited! (#{retry_after}ms)", state)

                # Notify all other handlers that a global rate limite was encountered
                Global.set_retry_after(name, retry_after)

                retry_after

              %{global: false, reset_after: reset_after} ->
                warn("Locally rate limited! (#{reset_after}ms)", state)

                reset_after
            end

          Process.sleep(wait_time)

          # Try again
          do_request(message, state)
        else
          new_state = %{
            state
            | bucket_hash: rl_headers[:bucket],
              rl_info: RateLimiter.to_info(rl_headers)
          }

          if rl_headers[:remaining] != 0 do
            {:ok, tuple, new_state}
          else
            {:ok, tuple, new_state, rl_headers.reset_after}
          end
        end
    end
  end

  defp wait_global(%{name: name} = state) do
    case Global.get_retry_after(name) do
      retry_after when retry_after > 0 ->
        debug("Globally rate limited, sleeping #{retry_after}ms.", state)

        Process.sleep(retry_after)

        # Recurse to check again, only return if actually not rate limited anymore
        wait_global(state)

      _retry_after ->
        :ok
    end
  end

  defp log_response(response, rl_headers, state) do
    debug(
      """
      Received a response.
      Status: #{response.status_code}
      Rate limit info:
      Limit: #{rl_headers[:remaining]} / #{rl_headers[:limit]}
      Reset: #{rl_headers[:reset_after]}ms / #{rl_headers[:reset]}
      Bucket: #{rl_headers[:bucket]}
      Global: #{rl_headers[:global] || false}
      Retry-After: #{rl_headers[:retry_after]}
      """,
      state
    )
  end

  defp debug(str, %{type: type, identifier: identifier}) do
    require Logger
    Logger.debug("[#{type}-handler][#{identifier}]: #{str}")
  end

  defp warn(str, %{type: type, identifier: identifier}) do
    require Logger
    Logger.warn("[#{type}-handler][#{identifier}]: #{str}")
  end
end
