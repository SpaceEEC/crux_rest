defmodule Crux.Rest.HTTP do
  @moduledoc false

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  alias Crux.Rest.{Endpoints}

  # See: https://discordapp.com/developers/docs/reference#user-agent
  url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]
  @user_agent "DiscordBot (#{url}, v#{version})"

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Poison.encode!(body)

  def process_request_headers(headers) do
    headers
    |> Keyword.put_new(:"content-type", "application/json")
    |> Keyword.put_new(:"user-agent", @user_agent)
  end

  def request(%Crux.Rest.Request{
        method: method,
        path: path,
        data: data,
        headers: headers,
        params: nil
      }) do
    request(
      method,
      path,
      data,
      headers
    )
  end

  def request(%Crux.Rest.Request{
        method: method,
        path: path,
        data: data,
        headers: headers,
        params: params
      }) do
    request(
      method,
      path,
      data,
      headers,
      params: params
    )
  end

  @spec request(
          method :: atom(),
          route :: String.t(),
          body :: term(),
          headers :: [{name :: String.t() | atom(), value :: String.t()}],
          options :: Keyword.t()
        ) :: :ok | {:ok, term()} | {:error, term()}
  def request(method, route, body, headers, options) do
    super(method, Endpoints.base_url() <> route, body, headers, options)
    |> handle_response()
  end

  defp handle_response({:error, _} = error), do: error
  # for 204, etc
  defp handle_response({:ok, %HTTPoison.Response{body: ""}} = res), do: res

  defp handle_response({:ok, %HTTPoison.Response{body: body} = res}) do
    body
    |> Poison.decode()
    |> case do
      {:ok, body} ->
        {:ok, %{res | body: body}}

      _ ->
        {:ok, body}
    end
  end
end
