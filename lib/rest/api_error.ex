defmodule Crux.Rest.ApiError do
  @moduledoc """
  Represents a Discord API error.

  Raised or returned whenever the api responded with a non `2xx` status code.
  """
  @moduledoc since: "0.1.0"

  alias Crux.Rest.{HTTP, Request}

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
  | `status_code` | The [HTTP Response code](https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#http-http-response-codes)      | `400`, `404`, `403` |
  | `code`        | Discord's [JSON Error Code](https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#json-json-error-codes)      | `10006`, `90001`    |
  | `message`     | Message describing the error                                                                                                   | `Unknown Invite`    |
  | `path`        | Path of the request                                                                                                            | `/invites/broken`   |
  | `method`      | HTTP verb of the request                                                                                                       | :get, :post, :patch |

  In case an error response was sent by CloudFlare, `code` will be `nil` and `message` a HTML document describing the error.
  """
  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          # The dialyzer insisted
          __exception__: true,
          status_code: integer(),
          code: integer() | nil,
          message: String.t(),
          path: String.t(),
          method: Request.method()
        }

  @doc """
  Default implementation only providing a `message` for `raise/2`.

  Not internally used.
  """
  @typedoc since: "0.1.0"
  @spec exception(message :: binary()) :: Exception.t()
  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  @doc """
  Creates a full `t:Crux.Rest.ApiError.t/0` struct, returned / raised by all `Crux.Rest` functions in case of an API error.
  """
  @doc since: "0.1.0"
  @spec exception(
          Request.t(),
          HTTP.response()
        ) :: t()
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

  # This clause handles HTML responses sent by CloudFlare
  # despite having an "Accept: application/json" header.
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
