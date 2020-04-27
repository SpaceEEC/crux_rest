defmodule Crux.Rest.Request do
  @moduledoc """
  Struct representing an executable request.
  """
  @moduledoc since: "0.2.0"

  alias Crux.Structs
  alias Mix.Project

  # See: https://discordapp.com/developers/docs/reference#user-agent
  url = Project.config()[:source_url]
  version = Project.config()[:version]
  @user_agent "DiscordBot (#{url}, v#{version})"

  @methods ~w(get put patch post delete)a

  @enforce_keys [:method, :path, :route]
  defstruct [
    :method,
    :route,
    :path,
    :version,
    :transform,
    :params,
    :major,
    data: "",
    headers: [
      accept: "application/json",
      "content-type": "application/json",
      "x-ratelimit-precision": "millisecond",
      "user-agent": @user_agent
    ],
    auth: true
  ]

  @typedoc """
  * `:method` HTTP verb to use
  * `:route` Used to group requests pre buckets
  * `:major` Used to rate limit using bucket hashes
  * `:path` URL path
  * `:version` Discord REST API version to use
  * `:data` Request body
  * `:headers` HTTP headers to use
  * `:params` URL path params to apply to the path
  * `:auth` Whether to use the bot token

  Ignore other fields.
  """
  @typedoc since: "0.2.0"

  @type t :: %__MODULE__{
          # HTTP verb
          method: method(),
          # Route for rate limit bucket
          route: String.t(),
          # Used in combination with a bucket hash
          major: String.t() | nil,
          # Path for HTTP
          path: String.t(),
          # REST API version to use
          version: integer() | nil,
          # Transform to return transformed data (structs, etc)
          transform: nil | atom() | (term() -> term()),
          # HTTP body
          data: term(),
          # HTTP headers
          headers: keyword(),
          # HTTP querystring parameter
          params: [{String.t(), String.t()}] | nil,
          # Whether to use a token
          auth: boolean()
        }

  @typedoc """
  Used HTTP verbs.
  """
  @typedoc since: "0.2.0"
  @type method :: :get | :put | :patch | :post | :delete

  @doc false
  @doc since: "0.2.0"
  @spec new(method :: method(), path :: String.t(), data :: term()) :: t()
  def new(method, path, data \\ "")

  def new(method, path, data)
      when is_binary(path) and method in @methods do
    %__MODULE__{
      method: method,
      route: get_route(path),
      major: get_major(path),
      path: path,
      data: data
    }
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_headers(t(), headers :: keyword()) :: t()
  def put_headers(%__MODULE__{} = t, headers)
      when is_list(headers) do
    %{t | headers: Keyword.merge(t.headers, headers)}
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
      when is_atom(transform)
      when is_function(transform, 1) do
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
      %{t | headers: Keyword.put(headers, :"x-audit-log-reason", URI.encode(reason))}
    end
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_token(t(), token :: String.t()) :: t()
  def put_token(%__MODULE__{headers: headers} = t, token)
      when is_binary(token) do
    %{t | headers: Keyword.put(headers, :authorization, "Bot " <> token)}
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_version(t(), version :: integer() | nil) :: t()
  def put_version(%__MODULE__{} = t, version)
      when is_nil(version)
      when is_integer(version) do
    %{t | version: version}
  end

  @doc false
  @doc since: "0.3.0"
  @spec put_auth(t(), boolean()) :: t()
  def put_auth(%__MODULE__{} = t, auth)
      when is_boolean(auth) do
    %{t | auth: auth}
  end

  @doc """
  Transforms the given data to the expected value for the given `t:t/0`.
  """
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
  @doc since: "0.3.0"
  @spec get_major(String.t()) :: String.t() | nil
  def get_major(path) do
    case Regex.run(~r'(?:channels|guilds|webhooks)\/(\d+)', path) do
      nil -> nil
      [_path, major] -> major
    end
  end

  @doc false
  @doc since: "0.2.0"
  @spec get_route(String.t()) :: String.t()
  def get_route(path)
      when is_binary(path) do
    route = Regex.replace(~r'(?<!channels|guilds|webhooks)/\d+', path, "/:id")
    # Group all reaction endpoints together, as all of them share a bucket (and the limit is 1...)
    Regex.replace(~r'(?<=\/reactions)\/.+', route, "/*")
  end
end
