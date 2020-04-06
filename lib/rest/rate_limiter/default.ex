defmodule Crux.Rest.RateLimiter.Default do
  @moduledoc """
  Default module for `Crux.Rest.RateLimiter`.
  """

  @behaviour Crux.Rest.RateLimiter

  @impl Crux.Rest.RateLimiter
  def request(name, %Crux.Rest.Request{} = request, http) do
    %{} = Crux.Rest.RateLimiter.Default.Handler.Supervisor.dispatch_request(name, request, http)
  end

  @impl Crux.Rest.RateLimiter
  def start_link(arg) do
    Crux.Rest.RateLimiter.Default.Supervisor.start_link(arg)
  end

  def get_rate_limit_values(headers, acc \\ %{})
      when is_map(acc) do
    Enum.reduce(headers, acc, fn
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
    %{
      limit: rl_headers[:limit],
      remaining: rl_headers[:remaining],
      reset_after: rl_headers[:reset_after]
    }
  end
end
