defmodule Crux.Rest.RateLimiter.Default.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  use Supervisor

  alias Crux.Rest.RateLimiter.Default
  alias Crux.Rest.Opts

  @doc """
  Starts the default rate limiter supervisor linked to the current process, usually a supervisor.
  """
  @doc since: "0.3.0"
  @spec start_link(Opts.t()) :: Supervisor.on_start()
  def start_link(%{name: mod} = opts) do
    name = Opts.supervisor(mod)

    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl Supervisor
  @spec init(Opts.t()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(%{name: mod} = opts) do
    registry = Opts.registry(mod)

    children = [
      {Default.Global, opts},
      {Registry, [keys: :unique, name: registry]},
      {Default.Handler.Supervisor, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
