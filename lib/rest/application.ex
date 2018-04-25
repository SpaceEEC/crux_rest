defmodule Crux.Rest.Application do
  @moduledoc false

  use Application

  def start(_type, _args), do: Crux.Rest.Handler.Supervisor.start_link()
end
