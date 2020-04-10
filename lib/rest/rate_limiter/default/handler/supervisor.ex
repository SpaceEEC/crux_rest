defmodule Crux.Rest.RateLimiter.Default.Handler.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.Opts
  alias Crux.Rest.RateLimiter.Default.Handler

  use DynamicSupervisor

  ###
  # Client API
  ###

  @spec start_link(Crux.Rest.Opts.t()) :: Supervisor.on_start()
  def start_link(%{name: name} = opts) do
    name = Opts.handler_supervisor(name)

    DynamicSupervisor.start_link(__MODULE__, opts, name: name)
  end

  @spec dispatch(name :: atom(), map()) :: {:ok, Crux.Rest.HTTP.response()} | {:error, term()}
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
    name
    |> Opts.registry()
    |> Registry.lookup(id)
    |> case do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  defp start_child!(name, identifier) do
    name
    |> Opts.handler_supervisor()
    |> DynamicSupervisor.start_child({Handler, identifier})
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
