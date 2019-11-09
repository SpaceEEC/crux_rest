defmodule Crux.Rest.Version do
  @moduledoc false

  # TODO: Remove this as soon as 1.7.0 is required
  if Version.compare(System.version(), "1.7.0") != :lt do
    defmacro since(version) when is_binary(version) do
      quote do
        @doc since: unquote(version)
      end
    end

    defmacro modulesince(version) when is_binary(version) do
      quote do
        @moduledoc since: unquote(version)
      end
    end

    defmacro typesince(version) when is_binary(version) do
      quote do
        @typedoc since: unquote(version)
      end
    end

    defmacro deprecated(message) when is_binary(message) do
      quote do
        @doc deprecated: unquote(message)
      end
    end
  else
    defmacro since(version) when is_binary(version) do
      quote do
        @since unquote(version)
      end
    end

    defmacro modulesince(version) when is_binary(version), do: nil
    defmacro typesince(version) when is_binary(version), do: nil
    defmacro deprecated(message) when is_binary(message), do: nil
  end
end
