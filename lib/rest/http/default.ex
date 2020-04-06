defmodule Crux.Rest.HTTP.Default do
  @moduledoc """
  Default module for `Crux.Rest.HTTP` using `HTTPoison`.
  """

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  # credo:disable-for-lines:40 Credo.Check.Readability.Specs
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

  def request(_name, %Crux.Rest.Request{
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

  @spec request(Crux.Rest.Request.t()) :: :ok | {:ok, term()} | {:error, term()}
  def request(_name, %Crux.Rest.Request{
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

  # Make dialyzer happy
  def request(%HTTPoison.Request{} = request), do: super(request)

  # Prefix the api url to the given path.
  defp get_url(path, version) do
    Crux.Rest.Endpoints.base_url(version) <> path
  end
end
