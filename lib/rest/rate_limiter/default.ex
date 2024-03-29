defmodule Crux.Rest.RateLimiter.Default do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @behaviour Crux.Rest.RateLimiter

  alias Crux.Rest.{HTTP, Request}
  alias Crux.Rest.RateLimiter.Default.Handler.Supervisor, as: HandlerSupervisor
  alias Crux.Rest.RateLimiter.Default.Supervisor, as: RateLimitSupervisor

  @impl Crux.Rest.RateLimiter
  defdelegate child_spec(init_arg), to: RateLimitSupervisor

  @impl Crux.Rest.RateLimiter
  def request(name, request, http) do
    {_, _} = HandlerSupervisor.dispatch(name, new(request, http))
  end

  @doc false
  # Exposed for tests
  @spec new(Request.t(), HTTP.t(), term()) :: map()
  def new(request, http, dispatch \\ &HandlerSupervisor.dispatch/2) do
    %{
      request: request,
      http: http,
      dispatch: dispatch
    }
  end
end
