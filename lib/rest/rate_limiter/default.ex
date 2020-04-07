defmodule Crux.Rest.RateLimiter.Default do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @behaviour Crux.Rest.RateLimiter

  alias Crux.Rest.RateLimiter.Default.Supervisor, as: RateLimitSupervisor
  alias Crux.Rest.RateLimiter.Default.Handler.Supervisor, as: HandlerSupervisor

  @impl Crux.Rest.RateLimiter
  defdelegate child_spec(init_arg), to: RateLimitSupervisor

  @impl Crux.Rest.RateLimiter
  def request(name, request, http) do
    {_, _} = HandlerSupervisor.dispatch(name, new(request, http))
  end

  @doc false
  # Exposed for tests
  def new(request, http) do
    %{
      request: request,
      http: http,
      dispatch: &HandlerSupervisor.dispatch/2
    }
  end

  def get_rate_limit_values(headers) do
    Enum.reduce(headers, %{global: false}, fn
      {"x-ratelimit-global", value}, acc ->
        Map.put(acc, :global, value == "true")

      {"x-ratelimit-limit", value}, acc ->
        Map.put(acc, :limit, String.to_integer(value))

      {"x-ratelimit-remaining", value}, acc ->
        Map.put(acc, :remaining, String.to_integer(value))

      {"x-ratelimit-reset", value}, acc ->
        # s to ms
        reset = trunc(String.to_float(value) * 1000)
        Map.put(acc, :reset, reset)

      {"x-ratelimit-reset-after", value}, acc ->
        # s to ms
        reset_after = trunc(String.to_float(value) * 1000)
        Map.put(acc, :reset_after, reset_after)

      {"x-ratelimit-bucket", value}, acc ->
        Map.put(acc, :bucket, value)

      {"retry-after", value}, acc ->
        Map.put(acc, :retry_after, String.to_integer(value))

      _tuple, acc ->
        acc
    end)
  end

  def to_info(rl_headers) do
    Map.take(rl_headers, ~w/limit remaining reset_after/a)
  end
end
