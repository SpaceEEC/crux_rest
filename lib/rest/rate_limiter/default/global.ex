defmodule Crux.Rest.RateLimiter.Default.Global do
  @moduledoc false
  # Module handling the global rate limit's retry after value.
  @moduledoc since: "0.3.0"

  alias Crux.Rest.Opts

  use GenServer

  @retry_after :retry_after

  ###
  # Client API
  ###

  @doc """
  Starts the "global" rate limiter process.
  """
  @doc since: "0.3.0"
  @spec start_link(Crux.Rest.Opts.t()) :: Supervisor.on_start()
  def start_link(%{name: mod}) do
    name = Opts.global(mod)

    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Sets the retry after time of a global rate limit.
  """
  @doc since: "0.3.0"
  @spec set_retry_after(name :: module(), retry_after :: non_neg_integer()) :: non_neg_integer()
  def set_retry_after(name, retry_after) do
    name = Opts.global(name)

    GenServer.call(name, {@retry_after, retry_after})
  end

  @doc """
  Gets the retry after time of a global rate limit.
  Will be 0 if none is active.
  """
  @doc since: "0.3.0"
  @spec get_retry_after(name :: module()) :: non_neg_integer()
  def get_retry_after(name) do
    name = Opts.global(name)

    [{@retry_after, retry_after}] = :ets.lookup(name, @retry_after)

    max(0, retry_after - :os.system_time(:millisecond))
  end

  ###
  # Server API
  ###

  @impl GenServer
  def init(name) do
    ^name = :ets.new(name, [:named_table, read_concurrency: true])

    true = :ets.insert(name, {@retry_after, 0})

    {:ok, name}
  end

  @impl GenServer
  def handle_call({@retry_after, retry_after}, _from, name) do
    value = :os.system_time(:millisecond) + retry_after

    true = :ets.insert(name, {@retry_after, value})

    {:reply, retry_after, name}
  end
end
