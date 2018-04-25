defmodule Crux.Rest.Handler.Global do
  @moduledoc """
    Handles global rate limits and the average time offset to discord.

    All functions in `Crux.Rest` automatically use this module, you do not need to worry about it.
  """

  use GenServer

  @doc """
    Starts the global rate limite handler.
  """
  @spec start_link(route :: String.t()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
    Fetches the average out of the last ten offsets to discord servers in milliseconds.
  """
  @spec fetch_offset() :: integer
  def fetch_offset do
    GenServer.call(__MODULE__, :offset)
  end

  @doc """
    Adds an offset to the list of offsets.
  """
  @spec add_offset(offset :: integer) :: :ok
  def add_offset(nil), do: :ok

  def add_offset(offset) do
    GenServer.call(__MODULE__, {:offset, offset})
  end

  @doc """
    Fetches how long to wait until the global rate limit is over.
    Is not positive when not rate limited.
  """
  @spec fetch_global_wait() :: integer
  def fetch_global_wait do
    GenServer.call(__MODULE__, :retry)
  end

  @doc """
    Sets the global wait time if rate limited globally.
  """
  @spec set_global_wait(retry_after :: pos_integer()) :: :ok 
  def set_global_wait(retry_after) do
    GenServer.call(__MODULE__, {:retry, retry_after})
  end

  @doc false
  def init(_args) do
    offsets = []
    reset = 0
    {:ok, {offsets, reset}}
  end

  @doc false
  def handle_call(:offset, _from, {offsets, _reset} = state) when length(offsets) <= 0,
    do: {:reply, 0, state}

  @doc false
  def handle_call(:offset, _from, {offsets, _reset} = state) do
    offset =
      offsets
      |> Enum.sum()
      |> div(length(offsets))

    {:reply, offset, state}
  end

  @doc false
  def handle_call({:offset, offset}, _from, {offsets, reset}) do
    offsets = [offset | Enum.slice(offsets, 0..9)]

    {:reply, :ok, {offsets, reset}}
  end

  @doc false
  def handle_call(:retry, _from, {_offsets, reset} = state),
    do: {:reply, reset - :os.system_time(:milli_seconds), state}

  @doc false
  def handle_call({:retry, retry_after}, _from, {offsets, reset}) do
    reset = Enum.max(retry_after + :os.system_time(:milli_seconds), reset)

    {:reply, :ok, {offsets, reset}}
  end
end
