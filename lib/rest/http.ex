defmodule Crux.Rest.HTTP do
  @moduledoc false
  # Behavior module executing requests and returning potentially normalized data.
  @moduledoc since: "0.3.0"

  alias Crux.Rest.Request

  @typedoc """
  A module implementing this behaviour, for example `Crux.Rest.HTTP.Default`.
  """
  @typedoc since: "0.3.0"
  @type t :: module()

  @typedoc """
  Normalized response object containing:
  * `:status_code` the status code as an integer
  * `:header` The headers as a keyword with **downcased** string keys and values
  * `:body` The response JSON as a map or, if not json, the raw binary.
  """
  @typedoc since: "0.3.0"
  @type response :: %{
          body: map() | binary(),
          headers: [{String.t(), String.t()}],
          status_code: pos_integer(),
          request: Request.t(),
        }

  @doc """
  Executes a `t:Crux.Rest.Request.t/0`.
  """
  @doc since: "0.3.0"
  @callback request(Request.t()) :: {:ok, response()} | {:error, term()}

  @doc """
  Used to optionally start the HTTP module under a supervisor.
  """
  @doc since: "0.3.0"
  @callback child_spec(arg :: Crux.Rest.Opts.t()) :: Supervisor.child_spec()

  @optional_callbacks child_spec: 1
end
