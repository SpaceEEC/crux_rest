defmodule Crux.Rest.Impl.Injector do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @ratelimiter Crux.Rest.RateLimiter.Default
  @http Crux.Rest.HTTP.Default

  def inject(%{module: name}) do
    quoted_impl = get_quoted_impl()

    quote do
      @behaviour Crux.Rest

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

      # Insert the higher-level functions
      unquote_splicing(quoted_impl)

      defoverridable(Crux.Rest)
    end
  end

  def request(request, module, ratelimiter \\ @ratelimiter, http \\ @http)
      when is_struct(request) do
    case ratelimiter.request(module, request, http) do
      {:error, _err} = error ->
        error

      {:ok, %{status_code: 204}} ->
        :ok

      {:ok, %{status_code: code} = response} when code in 400..599 ->
        {:error, Crux.Rest.ApiError.exception(request, response)}

      {:ok, %{status_code: code, body: body}} when code in 200..299 ->
        {:ok, Crux.Rest.Request.transform(request, body)}

      {:ok, response} ->
        response
    end
  end

  def handle_response({:ok, %{body: body}}, request) do
    {:ok, Crux.Rest.Request.transform(request, body)}
  end

  defp get_quoted_impl() do
    for {function, arity} <-
          Crux.Rest.Impl.__info__(:functions) do
      arguments = Macro.generate_arguments(arity, nil)
      function! = String.to_atom(Atom.to_string(function) <> "!")

      quote do
        def unquote(function)(unquote_splicing(arguments)) do
          alias Crux.Rest.Impl.Injector
          require Injector
          request = Injector.call_impl(unquote(function), unquote(arguments))
          request(request)
        end

        def unquote(function!)(unquote_splicing(arguments)) do
          alias Crux.Rest.Impl.Injector
          require Injector
          request = Injector.call_impl(unquote(function), unquote(arguments))
          request!(request)
        end
      end
    end
  end

  @doc false
  # There must be a better way to achieve this.any(
  # This is done instead of using :erlang.apply/3 to get compiler warnings if something is wrong.
  # Returns AST calling Crux.Rest.Impl.{{function}}({{...arguments}})
  defmacro call_impl(function, arguments)
           when is_atom(function) and is_list(arguments) do
    {{:., [], [{:__aliases__, [alias: false], [:Crux, :Rest, :Impl]}, function]}, [], arguments}
  end
end
