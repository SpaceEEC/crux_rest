defmodule Crux.Rest.Handler.Global do
  @moduledoc false

  use GenServer

  @doc """
    Starts the global rate limite handler.
  """
  @spec start_link(name :: atom()) :: GenServer.on_start()
  def start_link(name) do
    name = Module.concat(name, Global)

    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @doc """
    Fetches how long to wait until the global rate limit is over.
    Is not positive when not rate limited.
  """
  @spec fetch_global_wait(name :: atom()) :: integer()
  def fetch_global_wait(name) do
    name
    |> Module.concat(Global)
    |> GenServer.call(:retry)
  end

  @doc """
    Sets the global wait time if rate limited globally.
  """
  @spec set_global_wait(name :: atom(), retry_after :: pos_integer()) :: :ok
  def set_global_wait(name, retry_after) do
    name
    |> Module.concat(Global)
    |> GenServer.call({:retry, retry_after})
  end

  @doc false
  @impl true
  def init(_) do
    offsets = []
    reset = 0
    {:ok, {offsets, reset}}
  end

  @doc false
  @impl true

  def handle_call(:retry, _from, {_offsets, reset} = state) do
    {:reply, reset - :os.system_time(:millisecond), state}
  end

  def handle_call({:retry, retry_after}, _from, {offsets, reset}) do
    reset = Enum.max(retry_after + :os.system_time(:millisecond), reset)

    {:reply, :ok, {offsets, reset}}
  end
end
