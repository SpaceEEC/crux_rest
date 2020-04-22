defmodule Crux.Rest.HTTP.Default do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @behaviour Crux.Rest.HTTP

  alias Crux.Rest.{HTTP, Opts, Request}
  alias HTTP.Default.Impl

  @spec request(opts :: Opts.t(), request :: Request.t()) :: {:ok, HTTP.response()} | {:error, term()}
  def request(%{} = opts, %Request{} = request) do
    request
    |> Opts.apply_options(opts)
    |> Impl.do_request()
  end
end
