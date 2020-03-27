defmodule Crux.Rest.Request do
  @moduledoc """
    Struct representing an executable request.
  """
  @moduledoc since: "0.2.0"

  alias Crux.Structs

  @methods ~w(get put patch post delete)a

  @enforce_keys [:method, :path, :route]
  defstruct [
    :method,
    :route,
    :path,
    :transform,
    :params,
    data: "",
    headers: []
  ]

  @typedoc false
  @typedoc since: "0.2.0"

  @opaque t :: %__MODULE__{
            # HTTP verb
            method: method(),
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
            params: list() | nil
          }

  @typedoc false
  @typedoc since: "0.2.0"
  @type method :: :get | :put | :patch | :post | :delete

  @doc false
  @doc since: "0.2.0"
  @spec new(method :: method(), path :: String.t(), data :: term()) :: t()
  def new(method, path, data \\ "")

  def new(method, path, data)
      when method in @methods do
    %__MODULE__{
      method: method,
      route: get_route(path),
      path: path,
      data: data
    }
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_headers(t(), headers :: keyword()) :: t()
  def put_headers(%__MODULE__{} = t, headers)
      when is_list(headers) do
    %{t | headers: headers}
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_params(t(), params :: keyword()) :: t()
  def put_params(%__MODULE__{} = t, params)
      when is_list(params) do
    %{t | params: params}
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_transform(t(), transform :: nil | atom() | (term() -> term())) :: t()
  def put_transform(%__MODULE__{} = t, transform)
      when is_atom(transform) or is_function(transform, 1) do
    %{t | transform: transform}
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_reason(t(), reason :: String.t() | nil) :: t()
  def put_reason(%__MODULE__{} = t, nil), do: t
  def put_reason(%__MODULE__{} = t, ""), do: t

  def put_reason(%__MODULE__{headers: headers} = t, reason)
      when is_binary(reason) do
    reason = String.trim(reason)

    if reason == "" do
      t
    else
      %{t | headers: [{"x-audit-log-reason", URI.encode(reason)} | headers]}
    end
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_token(t(), token :: String.t()) :: t()
  def put_token(%__MODULE__{headers: headers} = t, token)
      when is_binary(token) do
    %{t | headers: [{:authorization, "Bot " <> token} | headers]}
  end

  @doc false
  @doc since: "0.2.0"
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

  @doc false
  @doc since: "0.2.0"
  @spec get_route(t() | String.t()) :: String.t()
  def get_route(path)
      when is_binary(path) do
    route = Regex.replace(~r'(?<!channels|guilds|webhooks)/\d{16,19}', path, "/:id")
    # https://github.com/discordapp/discord-api-docs/issues/182
    Regex.replace(~r'(?<=\/reactions\/)[^\/]+', route, ":reaction")
  end
end
