defmodule Crux.Rest.HTTP.Default do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @behaviour Crux.Rest.HTTP

  alias Crux.Rest.{HTTP, Request}
  alias HTTP.Default.Impl

  @spec request(request :: Request.t()) :: {:ok, HTTP.response()} | {:error, term()}
  def request(%Request{} = request) do
    with {:ok, response} <- Impl.do_request(request) do
      {:ok, Map.put(response, :request, request)}
    end
  end
end
