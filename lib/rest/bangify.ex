defmodule Crux.Rest.Bangify do
  @moduledoc false
  @moduledoc since: "0.3.0"

  @doc """
  Accepts a block of AST and appends ! to all callback names and its return types.
  Discards all annotations that are not @doc and @callback.
  """
  @doc since: "0.3.0"
  defmacro bangify(do: {:__block__, [], block}) do
    bangified = Enum.flat_map(block, &update_annotation/1)

    {:__block__, [], block ++ bangified}
  end

  # Updates or removes an annotation
  defp update_annotation({:@, meta, [node]}) do
    case update_annotation_inner(node) do
      nil ->
        []

      node ->
        [{:@, meta, List.wrap(node)}]
    end
  end

  # Updates, removes, or simply passes the content of an annotation through.
  defp update_annotation_inner({:doc, meta, [doc]})
       when is_binary(doc) do
    {:doc, meta, [doc]}
  end

  defp update_annotation_inner({:doc, _meta, _nodes} = node) do
    node
  end

  defp update_annotation_inner({:callback, meta, [spec]}) do
    {:callback, meta, List.wrap(update_call_spec(spec))}
  end

  defp update_annotation_inner(_node) do
    nil
  end

  # Updates the actual spec by adding a bang after both the name and the result type.
  defp update_call_spec({:"::", meta, [call, result]}) do
    call = add_bang(call)
    result = add_bang(result)

    {:"::", meta, [call, result]}
  end

  # Handle union types, e.g. api_result | api_result(boolean)
  defp add_bang({:|, meta, nodes}) do
    {:|, meta, Enum.map(nodes, &add_bang/1)}
  end

  defp add_bang({name, meta, nodes}) do
    {String.to_atom(Atom.to_string(name) <> "!"), meta, nodes}
  end
end
