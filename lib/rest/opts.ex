defmodule Crux.Rest.Opts do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.{Opts, Request}

  defstruct(
    token: nil,
    raw: false,
    name: nil,
    version: 7
  )

  @typedoc since: "0.3.0"
  @type t :: %{
          token: String.t(),
          raw: boolean(),
          name: module(),
          version: integer() | nil
        }

  def transform(%{} = data) do
    opts = struct(__MODULE__, data)

    :ok = validate(opts)

    %__MODULE__{} = opts
  end

  # Validates the given options, raises an argument error if invalid.
  defp validate(%Opts{token: token})
       when not is_binary(token) do
    raise ArgumentError, """
    Expected :token to be a binary.

    Received #{inspect(token)}
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
  def apply_options(%{auth: auth} = request, %{
        raw: raw,
        version: version,
        token: token
      }) do
    request =
      if raw do
        Request.put_transform(request, nil)
      else
        request
      end

    request =
      if auth do
        Request.put_token(request, token)
      else
        request
      end

    Request.put_version(request, version)
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
