defmodule Mix.Tasks.Bangify do
  use Mix.Task

  alias Code.Typespec

  @path ["lib", "rest", "gen", "bang.ex"] |> Path.join()

  @module_template """
  defmodule Crux.Rest.Gen.Bang do
    @moduledoc false
    # Generated __generated__

    alias Crux.Rest.Version
    require Version

    defmacro __using__(:callbacks) do
      quote location: :keep do
        __callbacks__
      end
    end

    defmacro __using__(:functions) do
      quote location: :keep do
        __functions__
      end
    end
  end
  """

  @callback_template """
    @doc "The same as \`c:__name__/__arity__\`, but raises an exception if it fails."
    __version__
    __callback__
  """

  @function_template """
  @doc "See \`c:Crux.Rest.__name__/__arity__\`"
    __maybe_version__
    __maybe_spec__
    def __name__(__arguments_with_defaults__) do
      request = Crux.Rest.Functions.__name__(__arguments__)
      request(@name, request)
    end

    @doc "The same as \`c:Crux.Rest.__name__/__arity__\`, but raises an exception if it fails."
    __maybe_version__
    __maybe_spec!__
    def __name__!(__arguments_with_defaults__) do
      request = Crux.Rest.Functions.__name__(__arguments__)
      request!(@name, request)
    end
  """

  def run(_) do
    callbacks = callbacks()
    functions = functions()

    content =
      @module_template
      |> String.replace("__generated__", DateTime.utc_now() |> DateTime.to_iso8601())
      |> String.replace("__callbacks__", callbacks)
      |> String.replace("__functions__", functions)
      |> Code.format_string!(file: @path, line: 0)
      |> :erlang.iolist_to_binary()
      |> Kernel.<>("\n")

    @path
    |> File.write!(content)
  end

  def callbacks() do
    {:ok, callbacks} = Typespec.fetch_callbacks(Crux.Rest)
    callbacks = Map.new(callbacks)

    {:docs_v1, _anno, :elixir, _format, _module_doc, _meta, docs} = Code.fetch_docs(Crux.Rest)

    {callbacks, optional_callbacks} =
      docs
      |> Enum.map(&map_callback(&1, callbacks))
      |> Enum.unzip()

    callbacks = callbacks |> Enum.join("\n") |> String.slice(0..-2)

    optional_callbacks = optional_callbacks |> Enum.filter(&(&1 != "")) |> Enum.join(",\n ")

    optional_callbacks =
      "\n#Required for `Crux.Rest.Functions`\n    @optional_callbacks #{optional_callbacks}"

    callbacks <> optional_callbacks
  end

  def functions() do
    {:ok, callbacks} = Typespec.fetch_callbacks(Crux.Rest)
    callbacks = Map.new(callbacks)

    {:docs_v1, _anno, :elixir, _format, _module_doc, _meta, docs} =
      Code.fetch_docs(Crux.Rest.Functions)

    docs
    |> Enum.map_join("\n", &map_docs(&1, callbacks))
  end

  @spec map_callback(term(), term()) :: {String.t(), String.t()}
  defp map_callback({{:callback, name, arity}, _line, [], _doc, meta}, callbacks) do
    if String.ends_with?(name |> to_string(), "!") do
      {"", ""}
    else
      [callback] = Map.fetch!(callbacks, {name, arity})
      callback = "@callback #{name}!#{format_type_bang(callback)}"

      version = Map.get(meta, :since) || raise "Missing since for #{name}/#{arity}"
      version = ~s{Version.since("#{version}")}

      callback =
        @callback_template
        |> String.replace("__name__", name |> to_string())
        |> String.replace("__arity__", arity |> to_string())
        |> String.replace("__version__", version)
        |> String.replace("__callback__", callback)

      optional = "#{Atom.to_string(name)}!: #{arity}"

      {callback, optional}
    end
  end

  defp map_callback(_, _), do: {"", ""}

  defp map_docs({{:function, name, arity}, _anno, [signature], _doc, meta}, callbacks) do
    if String.ends_with?(name |> to_string(), "!") do
      ""
    else
      {maybe_spec!, maybe_spec} =
        callbacks
        |> Map.get({name, arity})
        |> case do
          [spec] ->
            {"@spec #{name}!#{format_type_bang(spec)}", "@spec #{name}#{format_type(spec)}"}

          nil ->
            {"", ""}
        end

      since =
        case meta do
          %{since: since} ->
            ~s{Version.since("#{since}")}

          _ ->
            ""
        end

      signature =
        signature
        |> String.replace(~r{^.+?\(|\)$}, "")

      arguments = signature |> String.replace(~r{ \\\\ .*?(?=,|$)}, "")

      @function_template
      |> String.replace("__maybe_spec__", maybe_spec)
      |> String.replace("__maybe_spec!__", maybe_spec!)
      |> String.replace("__name__", name |> to_string())
      |> String.replace("__arity__", arity |> to_string())
      |> String.replace("__arguments_with_defaults__", signature)
      |> String.replace("__maybe_version__", since)
      |> String.replace("__arguments__", arguments)
    end
  end

  defp format_type_bang({:type, _, :fun, [params, {:type, _, :union, types}]}) do
    return =
      types
      |> case do
        [{:atom, _, :ok} | _] ->
          ":ok"

        [
          {:type, _, :tuple, [{:atom, _, :ok}, other]} | _
        ] ->
          format_type(other)
      end

    "(#{format_type(params)}) :: #{return} | no_return()"
  end

  defp format_type_bang({:type, _, :fun, [params, {:atom, 0, :ok}]}) do
    "(#{format_type(params)}) :: :ok | no_return()"
  end

  defp format_type({:type, _, :fun, [params, return]}) do
    "(#{format_type(params)}) :: #{format_type(return)}"
  end

  defp format_type({:type, _, :product, types}) do
    Enum.map_join(types, ", ", &format_type/1)
  end

  defp format_type({:ann_type, _, [{:var, _, name}, type]}) do
    "#{Atom.to_string(name)} :: #{format_type(type)}"
  end

  defp format_type({:type, _, :union, types}) do
    Enum.map_join(types, " | ", &format_type/1)
  end

  defp format_type({:remote_type, _, types}) do
    types =
      types
      |> Enum.slice(0..-2)
      |> Enum.map(&format_type/1)
      |> Enum.map(fn
        ":" <> name -> name
        name -> name
      end)
      |> Enum.join(".")

    "#{types}()"
  end

  defp format_type({:user_type, _, name, []}) do
    "#{Atom.to_string(name)}()"
  end

  defp format_type({:type, _, name, []}) do
    "#{Atom.to_string(name)}()"
  end

  defp format_type({:type, _, :tuple, types}) do
    "{#{Enum.map_join(types, ", ", &format_type/1)}}"
  end

  defp format_type({:atom, _, nil}) do
    "nil"
  end

  defp format_type({:atom, _, name}) do
    inspect(name)
  end

  defp format_type({:type, _, :list, types}) do
    "[#{Enum.map_join(types, ", ", &format_type/1)}]"
  end

  defp format_type({:type, _, :map, fields}) do
    "%{#{Enum.map_join(fields, ", ", &format_type/1)}}"
  end

  defp format_type({:type, _, :map_field_assoc, [key, value]}) do
    "optional(#{format_type(key)}) => #{format_type(value)}"
  end

  defp format_type({:type, _, :map_field_exact, [key, value]}) do
    "required(#{format_type(key)}) => #{format_type(value)}"
  end
end
