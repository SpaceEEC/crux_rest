defmodule Crux.Rest.RateLimiter.Default.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.Opts
  alias Crux.Rest.RateLimiter.Default.Global
  alias Crux.Rest.RateLimiter.Default.Handler.Supervisor, as: HandlerSupervisor

  use Supervisor

  @doc """
  Starts the default rate limiter supervisor linked to the current process, usually a supervisor.
  """
  @doc since: "0.3.0"
  @spec start_link(Opts.t()) :: Supervisor.on_start()
  def start_link(%{name: name} = opts) do
    name = Opts.supervisor(name)

    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl Supervisor
  @spec init(Opts.t()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(%{name: name} = opts) do
    registry = Opts.registry(name)

    children = [
      {Global, opts},
      {Registry, [keys: :unique, name: registry]},
      {HandlerSupervisor, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
