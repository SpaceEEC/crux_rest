defmodule Crux.Rest.Base do
  @moduledoc false

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  alias Crux.Rest.{ApiError, Endpoints, MixProject, Handler}

  # Compile time constant so we can use it in guards
  @api_base Endpoints.base_url()
  # See: https://discordapp.com/developers/docs/reference#user-agent
  @user_agent "DiscordBot (#{MixProject.project()[:source_url]}, " <>
                "v#{MixProject.project()[:version]}"

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Poison.encode!(body)

  def process_request_headers(headers) do
    headers
    |> Keyword.put_new(:"content-type", "application/json")
    |> Keyword.put_new_lazy(:authorization, fn ->
      "Bot #{Application.fetch_env!(:crux_rest, :token)}"
    end)
    |> Keyword.put_new(:"user-agent", @user_agent)
  end

  @spec request(
          method :: atom(),
          route :: String.t(),
          body :: term(),
          headers :: [{name :: String.t() | atom(), value :: String.t()}],
          options :: Keyword.t()
        ) :: :ok | {:ok, term()} | {:error, term()}
  def request(method, route, body \\ "", headers \\ [], options \\ [])

  def request(method, route, %{reason: reason} = body, headers, options) do
    request(
      method,
      route,
      Map.delete(body, :reason),
      [{"x-audit-log-reason", URI.encode(reason)} | headers],
      options
    )
  end

  def request(method, route, body, headers, options) do
    super(method, @api_base <> route, body, headers, options)
  end

  @spec queue(
          method :: atom(),
          route :: String.t(),
          body :: term(),
          headers :: [{name :: String.t() | atom(), value :: String.t()}],
          options :: Keyword.t()
        ) :: :ok | {:ok, term()} | {:error, term()}
  def queue(method, route, body \\ "", headers \\ [], options \\ []) do
    {route, [method, route, body, headers, options]}
    |> Handler.queue()
    |> handle_response(method)
  end

  defp handle_response({:error, _} = error, _method), do: error
  defp handle_response({:ok, %HTTPoison.Response{status_code: 204}}, _method), do: :ok

  defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, _method)
       when code in 200..299 do
    with {:error, _} <- Poison.decode(body) do
      {:error, {:decoding, body}}
    end
  end

  defp handle_response(
         {
           :ok,
           %HTTPoison.Response{
             status_code: status_code,
             body: body,
             request_url: @api_base <> path
           }
         },
         method
       ) do
    with {:ok, body} <- Poison.decode(body) do
      error = ApiError.exception(body, status_code, path, method)

      {:error, error}
    else
      {:error, _} ->
        {:error, {:decoding, body}}
    end
  end
end
