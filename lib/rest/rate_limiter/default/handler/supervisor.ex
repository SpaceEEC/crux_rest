defmodule Crux.Rest.RateLimiter.Default.Handler.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  use DynamicSupervisor

  alias Crux.Rest.RateLimiter.Default.Handler
  alias Crux.Rest.Opts

  @bucket :bucket
  @request :request

  @types [@bucket, @request]

  ###
  # Client API
  ###

  def start_link(%{name: name} = opts) do
    name = Opts.handler_supervisor(name)

    DynamicSupervisor.start_link(__MODULE__, opts, name: name)
  end

  # Regular request from the interface
  def dispatch_request(name, request, http) do
    dispatch(name, @request, request.route, request, http)
  end

  def dispatch_bucket(name, bucket_hash, request, http) do
    dispatch(name, @bucket, bucket_hash, request, http)
  end

  # Custom dispatch, e.g. request -> bucket handler
  defp dispatch(name, type, identifier, request, http) do
    pid =
      case lookup(name, type, identifier) do
        {:ok, pid} -> pid
        :error -> start_child!(name, type, identifier)
      end

    Handler.dispatch(pid, request, http)
  end

  # Look for the pid in the registry
  defp lookup(name, type, identifier)
       when type in @types and is_binary(identifier) do
    name = Opts.registry(name)

    case Registry.lookup(name, {type, identifier}) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  # Start the given process or fail horribly.
  defp start_child!(name, type, identifier) do
    name = Opts.handler_supervisor(name)

    child = {Handler, {type, identifier}}

    DynamicSupervisor.start_child(name, child)
    |> case do
      {:ok, pid} -> pid
      {:ok, pid, _info} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  ###
  # Server API
  ###

  @impl DynamicSupervisor
  def init(opts) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [opts]
    )
  end
end
