defmodule Crux.Rest.Handler.State do
  @moduledoc false
  use GenServer

  alias Crux.Rest.Version
  require Version

  Version.modulesince("0.2.0")

  @doc false
  def start_link({name, _state} = args) do
    name =
      name
      |> Module.concat(State)

    GenServer.start_link(__MODULE__, args, name: name)
  end

  @doc false
  Version.since("0.2.0")

  def init({name, state}) do
    name =
      name
      |> Module.concat(State)
      |> :ets.new([:named_table, read_concurrency: true])

    :ets.insert(name, Map.to_list(state))

    {:ok, nil}
  end

  @doc false
  Version.since("0.2.0")
  @spec token!(name :: atom()) :: String.t() | nil
  def token!(name) do
    name
    |> Module.concat(State)
    |> :ets.lookup(:token)
    |> extract!(:token)
  end

  @doc false
  Version.since("0.2.0")
  @spec retry_limit!(name :: atom()) :: non_neg_integer() | :infinity | nil
  def retry_limit!(name) do
    name
    |> Module.concat(State)
    |> :ets.lookup(:retry_limit)
    |> extract!(:retry_limit)
  end

  defp extract!([{key, val}], key), do: val
end
