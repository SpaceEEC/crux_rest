defmodule Crux.Rest.RateLimiter.Default.Handler do
  use GenServer

  alias Crux.Rest.RateLimiter.Default, as: RateLimiter
  alias Crux.Rest.RateLimiter.Default.Global
  alias Crux.Rest.RateLimiter.Default.Handler.Supervisor, as: HandlerSupervisor
  alias Crux.Rest.Opts

  @bucket :bucket
  @request :request

  @timeout 10_000

  defstruct [:name, :type, :identifier, :rate_limit_info, :bucket_hash]

  ###
  # Client API
  ###

  def child_spec({_type, _identifier} = tuple) do
    %{
      id: tuple,
      start: {__MODULE__, :start_link, [tuple]},
      restart: :temporary
    }
  end

  @spec start_link(Opts.t(), {any, any}) :: GenServer.on_start()
  def start_link(%{name: name} = opts, {_type, _identifier} = tuple) do
    registry = Opts.registry(name)

    name = {:via, Registry, {registry, tuple}}
    GenServer.start_link(__MODULE__, {opts, tuple}, name: name)
  end

  def dispatch(pid, request, http) do
    GenServer.call(pid, {request, http}, :infinity)
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

  @impl GenServer
  def handle_continue(reset_after, state) do
    debug(
      "Exhausted request limit, waiting remaining #{reset_after}ms before handling further messages.",
      state
    )

    Process.sleep(reset_after)

    {:noreply, state, @timeout}
  end

  # No bucket_hash known, make request directly
  @impl GenServer
  def handle_call(
        {request, http},
        _from,
        %__MODULE__{type: @request, bucket_hash: nil} = state
      ) do
    debug("Got message, no bucket_hash, making request in-place.", state)

    {rl_headers, response} = do_request(request, http, state)

    new_state = %{
      state
      | rate_limit_info: RateLimiter.to_info(rl_headers),
        bucket_hash: rl_headers[:bucket]
    }

    if new_state.bucket_hash do
      debug("Got a bucket_hash: #{new_state.bucket_hash}", state)
    end

    reply(new_state, response)
  end

  # Bucket hash known, forward request and check for bucket change.
  def handle_call(
        {request, http},
        _from,
        %__MODULE__{type: @request, bucket_hash: bucket_hash, name: name} = state
      ) do
    debug("Dispatching request to bucket #{bucket_hash}...", state)

    {rl_headers, response} = HandlerSupervisor.dispatch_bucket(name, bucket_hash, request, http)

    new_state =
      if rl_headers[:bucket] != bucket_hash do
        %{state | bucket_hash: rl_headers[:bucket]}
      else
        state
      end

    {:reply, response, new_state}
  end

  # Bucket handler, make request, handle rate limit, etc...
  def handle_call({request, http}, _from, %__MODULE__{type: @bucket} = state) do
    tuple = {rl_headers, _response} = do_request(request, http, state)

    new_state = %{
      state
      | rate_limit_info: RateLimiter.to_info(rl_headers)
    }

    reply(new_state, tuple)
  end

  # Exhausted the bucket, wait before processing further requests.
  defp reply(
         %__MODULE__{rate_limit_info: %{remaining: 0, reset_after: reset_after}} = state,
         response
       ) do
    {:reply, response, state, {:continue, reset_after}}
  end

  # Rate limit info available, set a timeout of the greater of @timeout or reset_after.
  defp reply(
         %__MODULE__{rate_limit_info: %{reset_after: reset_after}} = state,
         response
       ) do
    {:reply, response, state, max(@timeout, reset_after)}
  end

  # No rate limit info available, set the regular timeout.
  defp reply(%__MODULE__{rate_limit_info: nil} = state, response) do
    {:reply, response, state, @timeout}
  end

  defp do_request(
         request,
         http,
         %__MODULE__{name: name} = state
       ) do
    wait_global(state)

    debug("Making request.", state)

    case http.request(name, request) do
      {:error, _error} = tuple ->
        tuple

      {:ok, response} ->
        rl_headers = RateLimiter.get_rate_limit_values(response.headers)

        log_response(response, rl_headers, state)

        wait_time = wait_429(response, rl_headers, state)

        if wait_time > 0 do
          Process.sleep(wait_time)

          do_request(request, http, state)
        else
          {rl_headers, response}
        end
    end
  end

  defp wait_429(%{status_code: 429}, %{global: true} = rl_headers, %{name: name} = state) do
    warn("Received a global rate limit (#{rl_headers.retry_after}ms)", state)

    Global.set_retry_after(name, rl_headers.retry_after)

    rl_headers.retry_after
  end

  defp wait_429(%{status_code: 429}, %{global: false} = rl_headers, state) do
    warn("Received a local rate limit (#{rl_headers.reset_after}ms)", state)

    rl_headers.reset_after
  end

  defp wait_429(_response, _rl_headersl, _state) do
    0
  end

  defp wait_global(%__MODULE__{name: name} = state) do
    case Global.get_retry_after(name) do
      retry_after when retry_after > 0 ->
        debug("Globally rate limited, sleeping #{retry_after}ms...", state)

        Process.sleep(retry_after)

        # Recurse to check again
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
