defmodule Mix.Tasks.Bangify do
  use Mix.Task

  alias Code.Typespec

  @module_template """
  defmodule Crux.Rest.Bang do
    @moduledoc false
    # Generated __generated__

    defmacro __using__(_) do
      quote location: :keep do
        __functions__
      end
    end
  end
  """

  @function_template """
    @doc "The same as \`__name__/__arity__\`, but raises an exception if it fails."
    __maybe_spec__
    def __name__!(__arguments_with_defaults__) do
      case Crux.Rest.__name__(__arguments__) do
        :ok ->
          :ok

        {:ok, res} ->
          res

        {:error, error} ->
          raise error
      end
    end
  """

  def run(_) do
    {:ok, specs} = Typespec.fetch_specs(Crux.Rest)
    specs = Map.new(specs)

    {:docs_v1, _anno, :elixir, _format, _module_doc, _meta, functions} =
      Code.fetch_docs(Crux.Rest)

    functions =
      functions
      |> Enum.map_join("\n", &map_docs(&1, specs))
      |> String.slice(0..-2)

    content =
      @module_template
      |> String.replace("__generated__", DateTime.utc_now() |> DateTime.to_iso8601())
      |> String.replace("__functions__", functions)
      |> Code.format_string!()

    ["lib", "rest", "bang.ex"]
    |> Path.join()
    |> File.write!(content)
  end

  defp map_docs({{:function, name, arity}, _anno, [signature], _doc, _meta}, specs) do
    signature =
      signature
      |> String.replace(~r{^.+?\(|\)$}, "")

    if String.ends_with?(name |> to_string(), "!") do
      ""
    else
      maybe_spec =
        specs
        |> Map.get({name, arity})
        |> case do
          [spec] ->
            "@spec #{name}!#{format_type(spec)}"

          nil ->
            ""
        end

      @function_template
      |> String.replace("__maybe_spec__", maybe_spec)
      |> String.replace("__name__", name |> to_string())
      |> String.replace("__arity__", arity |> to_string())
      |> String.replace("__arguments_with_defaults__", signature)
      |> String.replace(
        "__arguments__",
        signature |> String.replace(~r{ \\\\ .*?(?=,|$)}, "")
      )
    end
  end

  defp map_docs(_, _), do: ""

  defp format_type({:type, _, :fun, [params, {:type, _, :union, types}]}) do
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
      |> Enum.map(
        &case &1 do
          ":" <> name ->
            name

          name ->
            name
        end
      )
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
