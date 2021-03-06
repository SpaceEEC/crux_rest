defmodule Crux.Rest.HTTP do
  @moduledoc false

  # https://github.com/edgurgel/httpoison
  use HTTPoison.Base

  alias Mix.Project

  alias Crux.Rest.Endpoints

  # See: https://discord.com/developers/docs/reference#user-agent
  url = Project.config()[:source_url]
  version = Project.config()[:version]
  @user_agent "DiscordBot (#{url}, v#{version})"

  # Disable credo here, because the dialyzer can not work with overloaded contracts here
  # credo:disable-for-lines:40 Credo.Check.Readability.Specs
  def process_request_url(url) do
    super(Endpoints.base_url() <> url)
  end

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Jason.encode!(body)

  def process_request_headers(headers) do
    headers
    |> Keyword.put_new(:accept, "application/json")
    |> Keyword.put_new(:"content-type", "application/json")
    |> Keyword.put_new(:"x-ratelimit-precision", "millisecond")
    |> Keyword.put_new(:"user-agent", @user_agent)
  end

  def process_response(%HTTPoison.Response{body: ""} = res), do: res

  def process_response(%HTTPoison.Response{body: body} = res) do
    body
    |> Jason.decode()
    |> case do
      {:ok, body} ->
        %{res | body: body}

      _ ->
        res
    end
  end

  def request(%Crux.Rest.Request{
        method: method,
        path: path,
        data: data,
        headers: headers,
        params: nil
      }) do
    super(%HTTPoison.Request{
      method: method,
      url: path,
      headers: headers,
      body: data
    })
  end

  @spec request(Crux.Rest.Request.t()) :: :ok | {:ok, term()} | {:error, term()}
  def request(%Crux.Rest.Request{
        method: method,
        path: path,
        data: data,
        headers: headers,
        params: params
      }) do
    super(%HTTPoison.Request{
      method: method,
      url: path,
      headers: headers,
      body: data,
      options: [params: params]
    })
  end

  # Make dialyzer happy
  def request(%HTTPoison.Request{} = request), do: super(request)
end
