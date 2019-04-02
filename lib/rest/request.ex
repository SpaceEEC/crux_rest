defmodule Crux.Rest.Request do
  @moduledoc """
    Struct representing an executable request.
  """

  alias Crux.Rest.Version
  alias Crux.Structs
  require Version

  Version.modulesince("0.2.0")

  @enforce_keys [:method, :path]
  defstruct [
    :method,
    :route,
    :path,
    :transform,
    :rate_limit_reset,
    :params,
    data: "",
    headers: []
  ]

  @typedoc false
  Version.typesince("0.2.0")

  @type t :: %__MODULE__{
          # HTTP verb
          method: atom(),
          # Route for rate limit bucket
          route: String.t(),
          # Path for HTTP
          path: String.t(),
          # Transform to return transformed data (structs, etc)
          transform: nil | atom() | (term() -> term()),
          # HTTP body
          data: term(),
          # HTTP headers
          headers: list(),
          # HTTP querystring parameter
          params: list()
        }

  ### Create / Set

  @doc false
  Version.since("0.2.0")
  @spec new(method :: atom(), path :: String.t(), data: term()) :: t()
  def new(method, path, data \\ "")

  def new(method, path, data) do
    %__MODULE__{
      method: method,
      route: get_route(path),
      path: path,
      data: data
    }
  end

  @doc false
  Version.since("0.2.0")
  @spec set_headers(t(), headers :: list()) :: t()
  def set_headers(%__MODULE__{} = t, headers), do: %{t | headers: headers}

  @doc false
  Version.since("0.2.0")
  @spec set_params(t(), params :: list()) :: t()

  def set_params(%__MODULE__{} = t, params), do: %{t | params: params}

  @doc false
  Version.since("0.2.0")

  @spec set_transform(t(), transform :: nil | atom() | (term() -> term())) :: t()
  def set_transform(%__MODULE__{} = t, transform), do: %{t | transform: transform}

  @doc false
  Version.since("0.2.0")
  @spec set_reason(t(), reason :: String.t() | nil) :: t()
  def set_reason(%__MODULE__{} = t, nil), do: t
  def set_reason(%__MODULE__{} = t, ""), do: t

  def set_reason(%__MODULE__{headers: headers} = t, reason) do
    %{t | headers: [{"x-audit-log-reason", URI.encode(reason)} | headers]}
  end

  @doc false
  Version.since("0.2.0")
  @spec set_token(t(), token :: String.t() | nil) :: t()
  def set_token(%__MODULE__{headers: headers} = t, token) do
    %{t | headers: [{"authorization", "Bot " <> token} | headers]}
  end

  @doc false
  # https://github.com/discordapp/discord-api-docs/issues/182
  Version.since("0.2.0")
  @spec set_rate_limit_reset(t(), reset :: non_neg_integer() | nil) :: t()
  def set_rate_limit_reset(%__MODULE__{} = t, reset) do
    %{t | rate_limit_reset: reset}
  end

  ### End Create / Set

  ### Work

  @doc false
  Version.since("0.2.0")
  @spec transform(t(), data :: term()) :: term()
  def transform(%__MODULE__{transform: nil}, data), do: data

  def transform(%__MODULE__{transform: struct}, data)
      when is_atom(struct) do
    Structs.create(data, struct)
  end

  def transform(%__MODULE__{transform: fun}, data)
      when is_function(fun, 1) do
    fun.(data)
  end

  ### End Work

  ### Helper

  @doc false
  Version.since("0.2.0")

  @spec get_route(String.t()) :: String.t()
  def get_route(path) do
    route = Regex.replace(~r'(?<!channels|guilds|webhooks)/\d{16,19}', path, "/:id")
    # https://github.com/discordapp/discord-api-docs/issues/182
    Regex.replace(~r'(?<=\/reactions\/)[^\/]+', route, ":reaction")
  end

  ### End Helper
end
