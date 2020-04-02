defmodule Crux.Rest.Opts do
  # TODO: Move this to somewhere where it makes sense to be

  @typedoc """
  * `:name` The name of the base module defined by the user
  """
  @typedoc since: "0.3.0"
  @type t :: %{
          name: module()
        }
end
