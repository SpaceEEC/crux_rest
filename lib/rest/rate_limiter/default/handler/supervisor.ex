defmodule Crux.Rest.RateLimiter.Default.Handler.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  use DynamicSupervisor

  alias Crux.Rest.RateLimiter.Default.Handler
  alias Crux.Rest.Opts

  ###
  # Client API
  ###

  def start_link(%{name: name} = opts) do
    name = Opts.handler_supervisor(name)

    DynamicSupervisor.start_link(__MODULE__, opts, name: name)
  end

  def dispatch(name, message) do
    identifier = get_identifier(message)

    pid =
      case lookup(name, identifier) do
        {:ok, pid} -> pid
        :error -> start_child!(name, identifier)
      end

    Handler.dispatch(pid, message)
  end

  defp lookup(name, id) do
    registry = Opts.registry(name)

    Registry.lookup(registry, id)
    |> case do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  defp start_child!(name, identifier) do
    handler_supervisor = Opts.handler_supervisor(name)

    DynamicSupervisor.start_child(handler_supervisor, {Handler, identifier})
    |> case do
      {:ok, pid} -> pid
      {:ok, pid, _info} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp get_identifier(%{bucket_hash: bucket_hash}) do
    {Handler.bucket(), bucket_hash}
  end

  defp get_identifier(%{request: %{route: route}}) do
    {Handler.request(), route}
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
