defmodule Crux.Rest.RateLimiter do
  @moduledoc """
  Behavior module handling rate limitting and preemptive throttling which the Discord API expects.
  """
  @moduledoc since: "0.3.0"

  alias Crux.Rest.{HTTP, Request}

  @callback request(
              # TODO: specify this
              name :: atom(),
              request :: Request.t(),
              http :: HTTP.t()
            ) :: {:ok, HTTP.response()} | {:error, term()}

  @doc """
  Used to optionally start the rate limiter module under a supervisor.
  """
  @doc since: "0.3.0"
  @callback child_spec(arg :: Crux.Rest.Opts.t()) :: Supervisor.child_spec()

  @optional_callbacks child_spec: 1
end
