defmodule Crux.Rest.Supervisor do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.Opts

  use Supervisor

  @spec start_link(Opts.t()) :: Supervisor.on_start()
  def start_link(opts) do
    opts = Opts.transform(opts)

    Supervisor.start_link(__MODULE__, opts, [])
  end

  @spec init(Opts.t()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(opts) do
    children = [
      {Crux.Rest.RateLimiter.Default, opts}
      # Does not need supervision
      # {Crux.Rest.HTTP.Default, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
