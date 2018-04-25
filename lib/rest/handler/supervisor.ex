defmodule Crux.Rest.Handler.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    require Logger
    Logger.info("[Crux][Rest][Handler][Supervisor]: init/1")

    children = [
      {Registry, keys: :unique, name: Crux.Rest.Handler.Registry},
      Supervisor.child_spec(
        Crux.Rest.Handler.Global,
        id: "global"
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_child(route) do
    Supervisor.start_child(
      __MODULE__,
      Supervisor.child_spec(
        {Crux.Rest.Handler, route},
        id: route,
        restart: :temporary
      )
    )
  end
end
