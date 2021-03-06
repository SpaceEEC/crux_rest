defmodule Crux.Rest.ApiError do
  @moduledoc """
    Represents a Discord API error.

    Raised or returned whenever the api responded with a non `2xx` status code
  """

  alias Crux.Rest.{Request, Version}
  require Version

  Version.modulesince("0.1.0")

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
  | `code`        | See Discord's [JSON Error Codes](https://discord.com/developers/docs/topics/opcodes-and-status-codes#json-json-error-codes) | `10006`, `90001`    |
  | `message`     | Message describing the error                                                                                                   | `Unknown Invite`    |
  | `path`        | Path of the request                                                                                                            | `/invites/broken`   |
  | `method`      | HTTP verb                                                                                                                      | :get, :post, :patch |
  """
  Version.typesince("0.1.0")

  @type t :: %__MODULE__{
          # The dialyzer insisted
          __exception__: true,
          status_code: integer(),
          code: integer() | nil,
          message: String.t(),
          path: String.t(),
          method: atom()
        }

  @doc """
    Default implementation only providing a `message` for `raise/2`
  """
  Version.since("0.1.0")
  @spec exception(message :: binary()) :: Exception.t()
  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  @doc """
    Creates a full `Crux.Rest.ApiError` struct, returned / raised by all `Crux.Rest` functions in case of an API error.
  """
  Version.since("0.1.0")

  @spec exception(
          Request.t(),
          HTTPoison.Response.t()
        ) :: __MODULE__.t()
  def exception(%{method: method, path: path}, %{
        status_code: status_code,
        body: %{"message" => message} = body
      }) do
    code = Map.get(body, "code")

    inner =
      body
      |> Map.get("errors")
      |> map_inner()

    message = if inner, do: "#{message}\n#{inner}", else: message

    %__MODULE__{
      status_code: status_code,
      code: code,
      message: message,
      path: path,
      method: method
    }
  end

  # Thank you, Cloudflare
  def exception(%{method: method, path: path}, %{status_code: status_code, body: message})
      when is_binary(message) do
    %__MODULE__{
      status_code: status_code,
      code: nil,
      message: message,
      path: path,
      method: method
    }
  end

  defp map_inner(error, key \\ nil)
  defp map_inner(nil, _key), do: nil

  defp map_inner(error, key) when is_map(error) do
    Enum.map_join(error, "\n", fn {k, v} ->
      new_k =
        cond do
          key && Regex.match?(~r/\d+/, k) -> "#{key}[#{k}]"
          key -> "#{key}.#{k}"
          true -> k
        end

      transform_value(new_k, v)
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
