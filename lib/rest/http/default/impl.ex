# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule Crux.Rest.HTTP.Default.Impl do
  @moduledoc false
  @moduledoc since: "0.3.0"

  # Apparently conflicting, although they are not
  # @behaviour Crux.Rest.HTTP

  alias Crux.Rest.{Endpoints, Request}

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Jason.encode!(body)

  def process_response(%HTTPoison.Response{body: ""} = res), do: res

  def process_response(%HTTPoison.Response{body: body} = res) do
    body
    |> Jason.decode()
    |> case do
      {:ok, body} ->
        %{res | body: body}

      _error ->
        res
    end
  end

  def do_request(%Request{
        method: method,
        path: path,
        version: version,
        data: data,
        headers: headers,
        params: nil
      }) do
    request(%HTTPoison.Request{
      method: method,
      url: get_url(path, version),
      headers: headers,
      body: data
    })
  end

  def do_request(%Request{
        method: method,
        path: path,
        version: version,
        data: data,
        headers: headers,
        params: params
      }) do
    request(%HTTPoison.Request{
      method: method,
      url: get_url(path, version),
      headers: headers,
      body: data,
      options: [params: params]
    })
  end

  # Prefix the api url to the given path.
  defp get_url(path, version) do
    Endpoints.base_url(version) <> path
  end
end
