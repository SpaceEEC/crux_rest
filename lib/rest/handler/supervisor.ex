defmodule Crux.Rest.Handler.Supervisor do
  @moduledoc false

  alias Crux.Rest.Handler
  alias Crux.Rest.Handler.State

  use Supervisor

  def start_link({name, _state} = args) do
    Supervisor.start_link(__MODULE__, args, name: name)
  end

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
