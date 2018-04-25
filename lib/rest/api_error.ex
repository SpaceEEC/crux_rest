defmodule Crux.Rest.ApiError do
  @moduledoc """
    Represents a Discord API error.

    Raised or returned whenever the api responded with a non `200` / `204` status code
  """
  defexception(
    status_code: nil,
    code: nil,
    message: nil,
    path: nil,
    method: nil
  )

  @typedoc """
  | Property      | Description                                                                                                                    | Example(s)          |
  | ------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------- |
  | `status_code` | HTTP status code                                                                                                               | `400`, `404`, `403` |
  |  `code`       | See Discord's [JSON Error Codes](https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#json-json-error-codes) | `10006`, `90001`    |
  | `message`     | Message describing the error                                                                                                   | `Unknown Invite`    |
  | `path`        | Path of the request                                                                                                            | `/invites/broken`   |
  """
  @type t :: %{
          status_code: integer,
          code: integer | nil,
          message: String.t(),
          path: String.t(),
          method: String.t()
        }

  @doc """
    Default implementation only providing a `message` for `raise/2`
  """
  @spec exception(message :: String.t()) :: __MODULE__.t()
  def exception(message) when is_bitstring(message) do
    %__MODULE__{message: message}
  end

  @doc """
    Creates a full `Crux.Rest.ApiError` struct, returned / raised by all `Crux.Rest` functions in case of an API error.
  """
  @spec exception(error :: map, status_code :: pos_integer, path :: String.t(), method :: String.t()) :: __MODULE__.t()
  def exception(%{"message" => message} = error, status_code, path, method) do
    code = Map.get(error, "code")

    inner =
      error
      |> Map.get("errors")
      |> map_inner()

    message = if inner, do: "#{message}\n#{inner}", else: message

    %__MODULE__{status_code: status_code, code: code, message: message, path: path, method: method}
  end

  defp map_inner(error, key \\ nil)
  defp map_inner(nil, _key), do: nil

  defp map_inner(error, key) when is_map(error) do
    Enum.map_join(error, "\n", fn {k, v} ->
      cond do
        key && Regex.match?(~r/\d+/, k) -> "#{key}[#{k}]"
        key -> "#{key}.#{k}"
        true -> k
      end
      |> transform_value(v)
    end)
  end

  defp map_inner(_error, _key), do: nil

  defp transform_value(_key, value) when is_bitstring(value), do: value

  defp transform_value(key, %{"_errors" => errors}),
    do: "#{key}: #{Enum.map_join(errors, " ", &Map.get(&1, "message"))}"

  defp transform_value(_key, %{"code" => code, "message" => message}), do: "#{code}: #{message}"
  defp transform_value(_key, %{"message" => message}), do: message
  defp transform_value(key, value), do: map_inner(value, key)
end
