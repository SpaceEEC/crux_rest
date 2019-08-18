defmodule Crux.Rest.Handler do
  @moduledoc false

  defstruct [:name, :retries, :route, :remaining, :reset, :timer]

  alias Crux.Rest.Handler.{Global, State}
  alias Crux.Rest.{Handler, HTTP, Request}

  require Logger

  use GenServer

  @doc """
    Starts a rate limit handler for the provided route.
  """
  @spec start_link({name :: atom(), route :: String.t()}) :: GenServer.on_start()
  def start_link({name, route} = args) do
    registry = Module.concat(name, Registry)

    name = {:via, Registry, {registry, route}}
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @doc """
  Queues a request, waits if necessary, and executes it.
  Blocks the calling process.

  Returns parsed response body on success.

  First element of the tuple is the route of the request.
  The second element is list of parameters passed via `:erlang.apply/3` to `HTTPoison.Base.request/5`.

  For the non API errors see `HTTPoison.Base.request/5` and `Jason.decode/2`.
  """
  @spec queue(name :: atom(), request :: Request.t()) :: term()
  def queue(name, %Request{route: route} = request) do
    name
    |> ensure_started(route)
    |> GenServer.call({:queue, request}, :infinity)
  end

  defp ensure_started(name, route) do
    registry = Module.concat(name, Registry)

    with [{pid, _other}] <- Registry.lookup(registry, route),
         true <- Process.alive?(pid) do
      pid
    else
      _ ->
        Handler.Supervisor.start_child(name, route)
        ensure_started(name, route)
    end
  end

  ### Server

  @doc false
  @impl true
  def init({name, route}) do
    Logger.debug(fn -> "[Crux][Rest][Handler][#{route}]: Starting" end)

    state = %__MODULE__{
      name: name,
      route: route,
      remaining: 1,
      retries: 0,
      reset: 0,
      timer: nil
    }

    {:ok, state}
  end

  @doc false
  # Handler is idle, shutdown
  @impl true
  def handle_info(:shutdown, %Handler{route: route} = state) do
    Logger.debug(fn -> "[Crux][Rest][Handler][#{route}]: Stopping idle handler" end)

    {:stop, :normal, state}
  end

  # Unexpected message
  def handle_info(other, %Handler{route: route} = state) do
    Logger.warn(fn ->
      "[Crux][Rest][Handler][#{route}]: Received unexpected message: #{inspect(other)}"
    end)

    {:noreply, state}
  end

  # Queue request, clear timer
  @impl true
  def handle_call({:queue, _request} = message, from, %Handler{timer: timer} = state)
      when not is_nil(timer) do
    :timer.cancel(timer)

    state = %{state | timer: nil}

    handle_call(message, from, state)
  end

  # Queue request, but we have to wait
  def handle_call(
        {:queue, _request} = message,
        from,
        %Handler{route: route, reset: reset, remaining: remaining} = state
      )
      when remaining <= 0 do
    wait(reset - :os.system_time(:millisecond), route)

    state = %{state | remaining: 1}

    handle_call(message, from, state)
  end

  # Queue request, actually execute
  def handle_call(
        {:queue, request} = message,
        from,
        %Handler{name: name, route: route} = state
      ) do
    wait(Global.fetch_global_wait(name), "global - " <> route)

    res =
      request
      |> Request.set_token(State.token!(name))
      |> HTTP.request()

    {state, wait} =
      state
      |> handle_headers(res)
      |> handle_response(res)

    if is_number(wait) do
      Logger.debug("[Crux][Rest][Handler][#{route}]: Waiting #{wait}ms")
      :timer.sleep(wait)

      handle_call(message, from, state)
    else
      reset_time =
        if is_integer(state.reset) do
          max(state.reset - :os.system_time(:millisecond), 0)
        else
          0
        end

      {:ok, ref} = :timer.send_after(reset_time, :shutdown)

      state = %{state | timer: ref}

      {:reply, res, state}
    end
  end

  # An error occured while executing the http request
  defp handle_headers(state, {:error, _}), do: state

  # Apply rate limit and date header
  defp handle_headers(
         %Handler{} = state,
         {:ok, %HTTPoison.Response{headers: headers}}
       ) do
    remaining =
      headers
      |> List.keyfind("X-RateLimit-Remaining", 0)
      |> parse_header()

    reset =
      headers
      |> List.keyfind("X-RateLimit-Reset-After", 0)
      |> parse_header()

    if remaining && reset do
      %{state | remaining: remaining, reset: reset}
    else
      state
    end
  end

  # Rate limited, figure out for how long and if globally
  @spec handle_response(term(), term()) :: {Handler.t(), non_neg_integer() | nil}
  defp handle_response(
         %Handler{name: name, route: route, reset: reset} = state,
         {:ok, %HTTPoison.Response{headers: headers, status_code: 429, body: body}}
       ) do
    Logger.warn("[Crux][Rest][Handler][#{route}] Received a 429")

    retry_after =
      case body do
        %{"retry_after" => retry_after} ->
          retry_after

        _ ->
          reset - :os.system_time(:millisecond)
      end

    if headers |> List.keyfind("X-RateLimit-Global", 0) |> parse_header() == true do
      Global.set_global_wait(name, retry_after)
    end

    {state, retry_after}
  end

  # Internal server error occured, retry if still within limit
  defp handle_response(
         %Handler{name: name, route: route, retries: retries} = state,
         {:ok, %HTTPoison.Response{status_code: code}}
       )
       when code in 500..599 do
    retry_limit = State.retry_limit!(name)

    if retry_limit != :infinity and retry_limit > retries do
      state = %{state | retries: retries + 1}

      Logger.warn(
        "[Crux][Rest][Handler][#{route}] Received a #{code}" <>
          " [#{state.retries}/#{retry_limit}]"
      )

      {state, 1500}
    else
      {state, nil}
    end
  end

  # All OK or retry limit reached, do nothing
  defp handle_response(state, res), do: {state, res}

  ### Helpers

  defp parse_header(nil), do: nil
  defp parse_header({"X-RateLimit-Global", _value}), do: true

  defp parse_header({"X-RateLimit-Remaining", value}), do: String.to_integer(value)

  defp parse_header({"X-RateLimit-Reset-After", value}) do
    {value, ""} = Float.parse(value)
    trunc(value * 1000) + :os.system_time(:millisecond)
  end

  defp wait(timeout, route) when timeout > 0 do
    Logger.debug("[Crux][Rest][Handler][#{route}]: Rate limited, waiting #{timeout}ms")

    :timer.sleep(timeout)
  end

  defp wait(_, _), do: :ok
end
