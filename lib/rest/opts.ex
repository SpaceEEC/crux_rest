defmodule Crux.Rest.Opts do
  @moduledoc false

  # TODO: Move this to somewhere where it makes sense to be

  @typedoc """
  * `:name` The name of the base module defined by the user
  """
  @typedoc since: "0.3.0"
  @type t :: %{
          token: String.t(),
          name: module()
        }

  def global(name) do
    Module.concat([name, RateLimiter.Global])
  end

  def registry(name) do
    Module.concat([name, RateLimiter.Registry])
  end

  def supervisor(name) do
    Module.concat([name, RateLimiter.Supervisor])
  end

  def handler_supervisor(name) do
    Module.concat([name, RateLimiter.Handler.Supervisor])
  end
end
