# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule Crux.Rest.Impl.Injector do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Rest.{ApiError, Impl, Request}

  @ratelimiter Crux.Rest.RateLimiter.Default
  @http Crux.Rest.HTTP.Default

  def inject(%{module: name}) do
    # request/1 and request!/1
    quoted_request = get_quoted_request(name)
    # start_link/1 and child_spec/1
    quoted_start = get_quoted_start(name)
    # All other behaviour functions of Crux.Rest
    quoted_impl = get_quoted_impl()

    quote do
      @behaviour Crux.Rest

      # request/1 and request!/1
      unquote(quoted_request)

      # start_link/1 and child_spec/1
      unquote(quoted_start)

      # Insert the rest of the behaviour functions
      alias Crux.Rest.Impl.Injector
      require Injector
      unquote_splicing(quoted_impl)

      defoverridable(Crux.Rest)
    end
  end

  # request/1 and request!/1
  defp get_quoted_request(name) do
    quote do
      def request(request) do
        unquote(__MODULE__).request(request, unquote(name))
      end

      def request!(request) do
        case request(request) do
          :ok -> :ok
          {:ok, data} -> data
          {:error, error} -> raise error
        end
      end
    end
  end

  # start_link/1 and child_spec/1
  defp get_quoted_start(name) do
    quote do
      def start_link(opts) do
        opts
        |> Map.new()
        |> Map.put(:name, unquote(name))
        |> Crux.Rest.Supervisor.start_link()
      end

      def child_spec(opts) do
        opts =
          opts
          |> Map.new()
          |> Map.put(:name, unquote(name))

        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          restart: :permanent,
          type: :supervisor
        }
      end
    end
  end

  # All other behaviour functions of Crux.Rest
  defp get_quoted_impl() do
    for {function, arity} <- Impl.__info__(:functions) do
      arguments = Macro.generate_arguments(arity, nil)
      function! = String.to_atom(Atom.to_string(function) <> "!")

      quote do
        def unquote(function)(unquote_splicing(arguments)) do
          request = Injector.call_impl(unquote(function), unquote(arguments))
          request(request)
        end

        def unquote(function!)(unquote_splicing(arguments)) do
          request = Injector.call_impl(unquote(function), unquote(arguments))
          request!(request)
        end
      end
    end
  end

  ###
  # Helpers
  ###

  @doc false
  # There must be a better way to achieve this.
  # This is done instead of using :erlang.apply/3 to get compiler warnings if something is wrong.
  # Returns AST calling Crux.Rest.Impl.{{function}}({{...arguments}})
  defmacro call_impl(function, arguments)
           when is_atom(function) and is_list(arguments) do
    {{:., [], [{:__aliases__, [alias: false], [:Crux, :Rest, :Impl]}, function]}, [], arguments}
  end

  @doc false
  # Executes the given requests and transforms the result, if appropriate
  # Returns an ok / error tuple
  def request(request, module, ratelimiter \\ @ratelimiter, http \\ @http) do
    case ratelimiter.request(module, request, http) do
      {:error, _err} = error ->
        error

      {:ok, %{status_code: 204}} ->
        :ok

      {:ok, %{status_code: code, request: request} = response} when code in 400..599 ->
        {:error, ApiError.exception(request, response)}

      {:ok, %{status_code: code, request: request, body: body}} when code in 200..299 ->
        {:ok, Request.transform(request, body)}

      {:ok, response} ->
        response
    end
  end
end
