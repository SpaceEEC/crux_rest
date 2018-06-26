defmodule Crux.Rest.Handler do
  @moduledoc """
    Handles per route rate limiting.

    All functions in `Crux.Rest` automatically use this module, you do not need to worry about it.
  """
  use GenServer

  require Logger

  import Crux.Rest.Handler.Global,
    only: [fetch_offset: 0, add_offset: 1, fetch_global_wait: 0, set_global_wait: 1]

  @max_retries_on_5xx 5

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

    {res, state} =
      apply(Crux.Rest.Base, :request, request_data)
      |> handle_headers(state)

    cond do
      is_number(res) ->
        Logger.debug("[Crux][Rest][Handler][#{route}]: Waiting #{res}ms")
        :timer.sleep(res)

        handle_call({:queue, request_data}, from, state)

      true ->
        reset_time =
          case state do
            %{reset: reset} when is_integer(reset) ->
              reset - :os.system_time(:milli_seconds)

            _ ->
              # 500 for sanity and in the case further messages are queued up
              500
          end

        {:ok, ref} = :timer.send_after(reset_time, :shutdown)

        {:reply, res, Map.put(state, :timer, ref)}
    end
  end

  defp handle_headers({:ok, %HTTPoison.Response{headers: headers}} = tuple, state) do
    List.keyfind(headers, "Date", 0)
    |> parse_header
    |> add_offset

    remaining =
      List.keyfind(headers, "X-RateLimit-Remaining", 0)
      |> parse_header

    reset =
      List.keyfind(headers, "X-RateLimit-Reset", 0)
      |> parse_header

    state =
      if remaining && reset do
        reset_milli_seconds = reset * 1000 + fetch_offset()
        Map.merge(state, %{remaining: remaining, reset: reset_milli_seconds})
      else
        state
      end

    handle_response(tuple, state, reset)
  end

  # Rate limited
  defp handle_response(
         {:ok, %HTTPoison.Response{headers: headers, status_code: 429, body: body}},
         %{route: route} = state,
         reset
       ) do
    Logger.warn("[Crux][Rest][Handler][#{route}] Received a 429")

    time =
      with {:ok, body} <- Poison.decode(body),
           # Incredible hacky
           {true, _} <- {
             List.keyfind(headers, "X-RateLimit-Global", 0) |> parse_header,
             body
           },
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

    {time, state}
  end

  # Retried too often, aborthing this
  defp handle_response(tuple, %{retries: retries} = state, _)
       when retries > @max_retries_on_5xx do
    {tuple, state}
  end

  # Retry on 5xx
  defp handle_response(
         {:ok, %HTTPoison.Response{status_code: code}},
         %{route: route} = state,
         _
       )
       when code >= 500 and code < 600 do
    Logger.warn(
      "[Crux][Rest][Handler][#{route}] Received a #{code} [#{Map.get(state, :retries, 0)}/#{
        @max_retries_on_5xx
      }]"
    )

    {1500, Map.update(state, :retries, 1, &(&1 + 1))}
  end

  # Success
  defp handle_response(tuple, state, _), do: {tuple, state}

  defp wait(timeout, route) when timeout > 0 do
    Logger.debug("[Crux][Rest][Handler][#{route}]: Rate limited, waiting #{timeout}ms")

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
