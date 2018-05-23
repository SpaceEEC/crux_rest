defmodule Crux.Rest.Base do
  @moduledoc false

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  alias Crux.Rest.{ApiError, Endpoints, Handler}

  # Compile time constant so we can use it in guards
  @api_base Endpoints.api()
  # See: https://discordapp.com/developers/docs/reference#user-agent
  @user_agent "DiscordBot (#{Crux.Rest.MixProject.project()[:source_url]}, v#{
                Crux.Rest.MixProject.project()[:version]
              }"

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

  defp handle_response({:ok, %HTTPoison.Response{status_code: 204}}, _method), do: :ok

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _method) do
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

  defp handle_response({:error, _} = error, _method), do: error

  def queue(method, route, body \\ "", headers \\ [], options \\ []) do
    {route, [method, route, body, headers, options]}
    |> Handler.queue()
    |> handle_response(method)
  end

  def request(method, route, body \\ "", headers \\ [], options \\ []) do
    [headers, body] =
      case body do
        %{reason: reason} ->
          headers = [{"x-audit-log-reason", URI.encode(reason)} | headers]
          body = Map.delete(body, :reason)

          [headers, body]

        _ ->
          [headers, body]
      end

    super(method, @api_base <> route, body, headers, options)
  end
end
