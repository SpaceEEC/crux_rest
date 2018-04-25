defmodule Crux.Rest.Handler do
  @moduledoc """
    Handles per route rate limiting.

    All functions in `Crux.Rest` automatically use this module, you do not need to worry about it.
  """
  use GenServer

  require Logger

  import Crux.Rest.Handler.Global,
    only: [fetch_offset: 0, add_offset: 1, fetch_global_wait: 0, set_global_wait: 1]

  @registry Crux.Rest.Handler.Registry

  @doc """
    Starts a rate limit handler for the provided route.
  """
  @spec start_link(route :: String.t()) :: GenServer.on_start()
  def start_link(route) do
    name = {:via, Registry, {@registry, route}}
    GenServer.start_link(__MODULE__, route, name: name)
  end

  @doc """
  Queues a request, waits if necessary, and executes it.
  Blocks the calling process.

  Returns parsed response body on success.

  First element of the tuple is the route of the request.
  The second element is list of parameters passed via `:erlang.apply/3` to `HTTPoison.Base.request/5`.

  For the non API errors see `HTTPPoison.Base.request/5` and `Poison.decode/2`.
  """
  @spec queue({String.t(), list()}) ::
          term()
          | {:error, HTTPoison.Error.t()}
          | {:error, {:decoding, :invalid | {:invalid, String.t()}}}
  def queue(request)

  def queue({route, request_data}) do
    route
    |> format_route()
    |> ensure_started()
    |> GenServer.call({:queue, request_data}, :infinity)
  end

  defp ensure_started(route) do
    with [{pid, _other}] <- Registry.lookup(@registry, route),
         true <- Process.alive?(pid) do
      pid
    else
      _ ->
        Crux.Rest.Handler.Supervisor.start_child(route)
        ensure_started(route)
    end
  end

  ## Server

  @doc false
  def init(route) do
    Logger.debug("[Crux][Rest][Handler][#{route}]: Starting")

    state = %{
      route: route,
      remaining: 1,
      reset: nil
      # timer: nil
    }

    {:ok, state}
  end

  @doc false
  def handle_info(:shutdown, %{route: route} = state) do
    Logger.debug("[Crux][Rest][Handler][#{route}]: Stopping idle handler")

    {:stop, :normal, state}
  end

  @doc false
  def handle_info(other, %{route: route} = state) do
    Logger.warn("[Crux][Rest][Handler][#{route}]: Received unexpected message: #{inspect(other)}")

    {:noreply, state}
  end

  @doc false
  def handle_call(
        {:queue, request_data},
        from,
        %{
          route: route,
          remaining: remaining,
          reset: reset
        } = state
      ) do
    state =
      case Map.pop(state, :timer) do
        {nil, state} ->
          state

        {timer, state} ->
          :timer.cancel(timer)

          state
      end

    # We reached the limit, wait
    if remaining <= 0, do: wait(reset + fetch_offset() - :os.system_time(:milli_seconds), route)

    # Wait if globally rate limited
    wait(fetch_global_wait(), "global - " <> route)

    {res, new_state} =
      apply(Crux.Rest.Base, :request, request_data)
      |> handle_headers(state)

    state = Map.merge(state, new_state)

    cond do
      is_number(res) ->
        Logger.debug("[Crux][Rest][Handler][#{route}]: Waiting #{res}ms")
        :timer.sleep(res)

        handle_call({:queue, request_data}, from, state)

      true ->
        wait_time =
          case state do
            %{reset: reset} when not is_nil(reset) ->
              reset - :os.system_time(:milli_seconds)

            _ ->
              # 500 for sanity and in the case further messages are queued up
              500
          end

        {:ok, ref} = :timer.send_after(wait_time, :shutdown)

        {:reply, res, Map.put(state, :timer, ref)}
    end
  end

  defp handle_headers(
         {:ok, %HTTPoison.Response{headers: headers, status_code: code, body: body}} = tuple,
         %{route: route}
       ) do
    List.keyfind(headers, "Date", 0)
    |> parse_header
    |> add_offset

    remaining =
      List.keyfind(headers, "X-RateLimit-Remaining", 0)
      |> parse_header

    reset =
      List.keyfind(headers, "X-RateLimit-Reset", 0)
      |> parse_header

    new_state =
      if remaining && reset,
        do: %{remaining: remaining, reset: reset * 1000},
        else: %{}

    res =
      cond do
        code === 429 ->
          Logger.warn("[Crux][Rest][Handler] Received a (429) for route #{route}")

          with {:ok, body} <- Poison.decode(body),
               # Incredible hacky
               {true, _} <- {List.keyfind(headers, "X-RateLimit-Global", 0) |> parse_header, body},
               {:ok, retry_after} <- Map.fetch(body, "retry_after") do
            set_global_wait(retry_after)
            retry_after
          else
            # Payload is not valid json, fallback to reset
            {:error, _} ->
              reset + fetch_offset() - :os.system_time(:milli_seconds)

            # Not Global
            {nil, %{"retry_after" => retry_after}} ->
              retry_after

            # Payload does not contain a retry_after, fallback to reset
            _ ->
              reset + fetch_offset() - :os.system_time(:milli_seconds)
          end

        # Retry on 5xx
        code >= 500 && code < 600 ->
          1500

        # Success
        true ->
          tuple
      end

    {res, new_state}
  end

  defp wait(timeout, route) when timeout > 0 do
    Logger.debug("[Crux][Rest][Handler]: Rate limited, waiting #{timeout}ms for #{route}")

    :timer.sleep(timeout)
  end

  defp wait(_, _), do: :ok

  defp parse_header(nil), do: nil
  defp parse_header({"X-RateLimit-Global", _value}), do: true

  defp parse_header({"Date", value}) do
    case Timex.parse(value, "{WDshort}, {D} {Mshort} {YYYY} {h24}:{m}:{s} {Zabbr}") do
      {:ok, date_time} ->
        :os.system_time(:milli_seconds) - DateTime.to_unix(date_time, :milli_seconds)

      {:error, _} ->
        nil
    end
  end

  defp parse_header({_name, value}), do: value |> String.to_integer()

  defp format_route(route),
    do: Regex.replace(~r'(?<!channels|guilds|webhooks)/\d{16,19}', route, "/:id")
end
