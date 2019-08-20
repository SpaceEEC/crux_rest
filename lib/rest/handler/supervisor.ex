defmodule Crux.Rest.Handler.Supervisor do
  @moduledoc false

  alias Crux.Rest.Handler
  alias Crux.Rest.Handler.State

  use Supervisor

  @spec start_link(term()) :: Supervisor.on_start()
  def start_link({name, _state} = args) do
    Supervisor.start_link(__MODULE__, args, name: name)
  end

  @spec init(term()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init({name, state}) do
    registry = Module.concat(name, Registry)

    state =
      state
      |> Map.new()
      |> Map.put_new(:retry_limit, 5)

    children = [
      {State, {name, state}},
      {Registry, keys: :unique, name: registry},
      {Handler.Global, name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec start_child(Supervisor.supervisor(), String.t()) :: Supervisor.on_start_child()
  def start_child(name, route) do
    Supervisor.start_child(
      name,
      Supervisor.child_spec(
        {Handler, {name, route}},
        id: route,
        restart: :temporary
      )
    )
  end
end
