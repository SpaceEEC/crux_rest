defmodule Crux.Rest.HTTP do
  @moduledoc """
  Behavior module executing requests and returning potentially normalized data.
  """
  @moduledoc since: "0.3.0"

  alias Crux.Rest.{ApiError, Request}

  @typedoc """
  A module implementing this behaviour, for example `Crux.Rest.HTTP.Default`.
  """
  @typedoc since: "0.3.0"
  @type t :: module()

  @typedoc """
  Normalized response object.
  """
  @typedoc since: "0.3.0"
  @type response :: %{
          body: map() | binary(),
          headers: [{String.t(), String.t()}],
          status_code: pos_integer()
        }

  @doc """
  Executes a `t:Crux.Rest.Request.t/0`.

  The returned map contains
  * `:status_code` the status code as an integer
  * `:header` The headers as a keyword with string keys and values
  * `:body` The response JSON as a map or, if not json, the raw binary.
  """
  @doc since: "0.3.0"
  @callback request(Request.t()) :: response()

  @doc """
  Transforms a response map to the expected data.
  See: `Crux.Rest.Request.transform/2` and `Crux.Rest.ApiError.exception/2`.
  """
  @doc since: "0.3.0"
  @callback transform(Request.t(), response()) ::
              :ok | {:ok, term()} | {:error, ApiError.t()}

  @optional_callbacks transform: 2

  @doc """
  Default implementation for `c:#{__MODULE__}.transform/2`.
  """
  @doc since: "0.3.0"
  @spec transform(Request.t(), response()) ::
          :ok | {:ok, term()} | {:error, ApiError.t()}
  def transform(_request, %{status_code: 204}) do
    :ok
  end

  def transform(request, %{status_code: code} = response)
      when code in 400..599 do
    {:error, ApiError.exception(request, response)}
  end

  def transform(request, %{body: body}) do
    {:ok, Request.transform(request, body)}
  end
end
