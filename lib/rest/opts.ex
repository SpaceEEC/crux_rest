defmodule Crux.Rest.Opts do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.{Opts, Request}

  defstruct(
    token: nil,
    token_type: "Bot",
    raw: false,
    name: nil,
    version: 9
  )

  @typedoc since: "0.3.0"
  @type t :: %{
          token: String.t(),
          token_type: String.t(),
          raw: boolean(),
          name: module(),
          version: integer() | nil
        }

  # The dialyzer REALLY dislikes Opts.t() as the return value here for whatever reason...
  # credo:disable-for-next-line Credo.Check.Readability.Specs
  def transform(%{} = data) do
    opts = struct(__MODULE__, data)

    :ok = validate(opts)

    opts
  end

  # Validates the given options, raises an argument error if invalid.
  defp validate(%Opts{token: token})
       when token == ""
       when not is_binary(token) do
    raise ArgumentError, """
    Expected :token to be a binary.

    Received #{inspect(token)}
    """
  end

  defp validate(%Opts{token_type: token_type})
       when token_type == ""
       when not is_binary(token_type) do
    raise ArgumentError, """
    Expected :token_type to be a string.

    Received #{inspect(token_type)}
    """
  end

  defp validate(%Opts{raw: raw})
       when not is_boolean(raw) do
    raise ArgumentError, """
    Expected :raw to be a boolean.

    Received #{inspect(raw)}
    """
  end

  defp validate(%Opts{version: version})
       when not is_nil(version) and not is_integer(version) do
    raise ArgumentError, """
    Expected :version to be nil or an integer.

    Received #{inspect(version)}
    """
  end

  defp validate(%Opts{name: name})
       when not is_atom(name) do
    raise ArgumentError, """
    Expected :name to be a module name.

    Received #{inspect(name)}
    """
  end

  defp validate(%Opts{}) do
    :ok
  end

  @doc """
  Applies options to the request
  """
  @spec apply_options(request :: Request.t(), opts :: Opts.t()) :: Request.t()
  def apply_options(request, %{version: version} = opts) do
    request
    |> apply_raw(opts)
    |> apply_auth(opts)
    |> Request.put_version(version)
  end

  defp apply_raw(request, %{raw: true}) do
    Request.put_transform(request, nil)
  end

  defp apply_raw(request, _opts) do
    request
  end

  defp apply_auth(%{auth: true} = request, %{token: token, token_type: token_type}) do
    Request.put_token(request, token, token_type)
  end

  defp apply_auth(request, %{token: _token, token_type: _token_type} = _opts) do
    request
  end

  @spec global(atom) :: atom
  def global(name) do
    Module.concat([name, RateLimiter.Global])
  end

  @spec registry(atom) :: atom
  def registry(name) do
    Module.concat([name, RateLimiter.Registry])
  end

  @spec supervisor(atom) :: atom
  def supervisor(name) do
    Module.concat([name, RateLimiter.Supervisor])
  end

  @spec handler_supervisor(atom) :: atom
  def handler_supervisor(name) do
    Module.concat([name, RateLimiter.Handler.Supervisor])
  end
end
