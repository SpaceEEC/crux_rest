defmodule Crux.Rest.RateLimiter do
  @moduledoc """

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
  Starts the rate limiter module linked to the current process, usually a supervisor.
  """
  @doc since: "0.3.0"
  @callback start_link(arg :: Crux.Rest.Opts.t()) :: Supervisor.on_start()
end
