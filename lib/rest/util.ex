defmodule Crux.Rest.Util do
  @moduledoc """
    Collection of util functions.
  """

  alias Crux.Structs.{
    Channel,
    Emoji,
    Guild,
    Member,
    Message,
    Overwrite,
    Reaction,
    Role,
    User
  }

  alias Crux.Rest.Version
  require Version

  Version.modulesince("0.1.0")

  ### Attachment / Image

  @typedoc """
    Used for functions setting an icon / image / etc.
    Can be either a `binary()` of an image or a data url.
  """
  Version.typesince("0.2.0")
  @type image :: binary() | String.t() | nil

  @doc """
    Used for functions resolving a `t:image/0` into base64 image data urls.
  """
  @spec resolve_image(image(), extension :: String.t()) :: String.t() | nil
  Version.since("0.2.0")
  def resolve_image(data, extension \\ "jpg")

  def resolve_image(nil, _), do: nil
  def resolve_image("data:" <> data, _), do: data

  def resolve_image(data, extension) do
    "data:image/#{extension};base64,#{Base.encode64(data)}"
  end

  @doc """
    Internally used to transform a `t:image/0` within a map to a base64 image data urls.
  """
  Version.since("0.2.0")
  @spec resolve_image_in_map(map(), atom()) :: map()
  def resolve_image_in_map(map, key) do
    case map do
      %{^key => value} ->
        image = resolve_image(value)
        Map.replace!(map, key, image)

      _ ->
        map
    end
  end

  @typedoc """
    Used to attach files via `c:Crux.Rest.create_message/2` or `c:Crux.Rest.execute_webhook/3`.

    This can be one of:

    |                  | Example                                      |
    | ---------------- | -------------------------------------------- |
    | `binary`         | `<<0, 0, 0, 0>>` (will be named "file.jpg")  |
    | `{binary, name}` | `{<<104, 101, 108, 108, 111>>, "hello.txt"}` |
  """
  Version.typesince("0.2.0")
  @type attachment :: binary() | {binary(), String.t()}

  # "Internally used to transform an `t:attachment/0` to a `:hackney_multipart` compatible part."
  Version.since("0.2.0")

  @spec transform_attachment(attachment()) ::
          {String.t(), binary(), disposition :: term(), headers :: list()}

  defp transform_attachment(attachment) when is_binary(attachment) do
    transform_attachment({attachment, "file.jpg"})
  end

  defp transform_attachment({attachment, name}) do
    disposition = {"form-data", [{"filename", "\"#{name}\""}]}
    headers = [{"content-type", :mimerl.filename(name)}]

    {name, attachment, disposition, headers}
  end

  @doc """
    Internally used to transform `t:Crux.Rest.execute_webhook_options/0` and  `t:Crux.Rest.create_message_data/0` to a tuple of `{body, extra_headers}`
  """
  Version.since("0.2.0")

  @spec resolve_multipart(map()) :: {{:multipart, list()} | map(), list()}
  def resolve_multipart(%{files: [_ | _] = files} = data) do
    multipart_files = Enum.map(files, &transform_attachment/1)

    form_data =
      if map_size(data) > 1 do
        payload_json =
          data
          |> Map.delete(:files)
          |> Poison.encode!()

        [{"payload_json", payload_json} | multipart_files]
      else
        multipart_files
      end

    {{:multipart, form_data}, [{"content-type", "multipart/form-data"}]}
  end

  def resolve_multipart(data), do: {data, []}

  ### End Attachment / Image

  ### Resolvables

  @typedoc """
    All available types that can be resolved into a role id.
  """
  Version.typesince("0.1.1")
  @type role_id_resolvable :: Role.t() | Crux.Rest.snowflake()

  @doc ~S"""
    Resolves a `t:role_id_resolvable/0` into a role id.

  ## Examples

    ```elixir
  # A role struct
  iex> %Crux.Structs.Role{id: 376146940762783746}
  ...> |> Crux.Rest.Util.resolve_role_id()
  376146940762783746

  # A role id
  iex> 376146940762783746
  ...> |> Crux.Rest.Util.resolve_role_id()
  376146940762783746

  """
  @spec resolve_role_id(role :: role_id_resolvable()) :: integer()
  Version.since("0.1.0")
  def resolve_role_id(%Role{id: role_id}), do: role_id
  def resolve_role_id(role_id) when is_number(role_id), do: role_id

  @typedoc """
    All available types that can be resolved into an emoji identifier.
  """
  Version.typesince("0.1.1")
  @type emoji_identifier_resolvable :: Reaction.t() | Emoji.t() | String.t()

  @typedoc """
    All available types that can be resolved into an emoji id.
  """
  Version.typesince("0.1.1")
  @type emoji_id_resolvable :: Reaction.t() | Emoji.t() | String.t()

  @doc ~S"""
    Resolves a `t:emoji_id_resolvable/0` into an emoji id.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Emoji{id: 396521773216301056}
  ...> |> Crux.Rest.Util.resolve_emoji_id()
  396521773216301056

  iex> %Crux.Structs.Reaction{emoji: %Crux.Structs.Emoji{id: 396521773216301056}}
  ...> |> Crux.Rest.Util.resolve_emoji_id()
  396521773216301056

  iex> 396521773216301056
  ...> |> Crux.Rest.Util.resolve_emoji_id()
  396521773216301056

    ```
  """
  @spec resolve_emoji_id(emoji :: emoji_id_resolvable()) :: String.t()
  Version.since("0.1.1")
  def resolve_emoji_id(%Emoji{id: id}) when not is_nil(id), do: id
  def resolve_emoji_id(%Reaction{emoji: emoji}), do: resolve_emoji_id(emoji)
  def resolve_emoji_id(emoji) when is_integer(emoji), do: emoji

  @typedoc """
    All available types that can be resolved into a user id.
  """
  Version.typesince("0.1.1")
  @type user_id_resolvable :: Member.t() | User.t() | integer()

  @doc ~S"""
    Resolves a `t:user_id_resolvable/0` into a user id.

  ## Examples

    ```elixir
  iex> %Crux.Structs.User{id: 218348062828003328}
  ...> |> Crux.Rest.Util.resolve_user_id()
  218348062828003328

  iex> %Crux.Structs.Member{user: 218348062828003328}
  ...> |> Crux.Rest.Util.resolve_user_id()
  218348062828003328

  iex> 218348062828003328
  ...> |> Crux.Rest.Util.resolve_user_id()
  218348062828003328

    ```
  """
  @spec resolve_user_id(user :: user_id_resolvable()) :: Crux.Rest.snowflake()
  Version.since("0.1.0")
  def resolve_user_id(%User{id: id}), do: id
  def resolve_user_id(%Member{user: id}), do: id
  def resolve_user_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a guild id.
  """
  Version.typesince("0.1.1")
  @type guild_id_resolvable :: Guild.t() | Channel.t() | Message.t() | Crux.Rest.snowflake()

  @doc ~S"""
    Resolves a `t:guild_id_resolvable/0` into a guild id.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Guild{id: 222078108977594368}
  ...> |> Crux.Rest.Util.resolve_guild_id()
  222078108977594368

  iex> %Crux.Structs.Channel{guild_id: 222078108977594368}
  ...> |> Crux.Rest.Util.resolve_guild_id()
  222078108977594368

  iex> %Crux.Structs.Message{guild_id: 222078108977594368}
  ...> |> Crux.Rest.Util.resolve_guild_id()
  222078108977594368

  iex> 222078108977594368
  ...> |> Crux.Rest.Util.resolve_guild_id()
  222078108977594368

    ```
  """
  @spec resolve_guild_id(guild :: guild_id_resolvable()) :: Crux.Rest.snowflake()
  Version.since("0.1.1")
  def resolve_guild_id(%Guild{id: id}), do: id
  def resolve_guild_id(%Channel{guild_id: id}) when not is_nil(id), do: id
  def resolve_guild_id(%Message{guild_id: id}) when not is_nil(id), do: id
  def resolve_guild_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a channel id.
  """
  Version.typesince("0.1.1")
  @type channel_id_resolvable :: Message.t() | Channel.t() | Crux.Rest.snowflake()

  @doc ~S"""
    Resolves a `t:channel_id_resolvable/0` into a channel id.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Channel{id: 222079895583457280}
  ...> |> Crux.Rest.Util.resolve_channel_id()
  222079895583457280

  iex> %Crux.Structs.Message{channel_id: 222079895583457280}
  ...> |> Crux.Rest.Util.resolve_channel_id()
  222079895583457280

  iex> 222079895583457280
  ...> |> Crux.Rest.Util.resolve_channel_id()
  222079895583457280

    ```
  """
  @spec resolve_channel_id(channel :: channel_id_resolvable()) :: Crux.Rest.snowflake()
  Version.since("0.1.1")
  def resolve_channel_id(%Channel{id: id}), do: id
  def resolve_channel_id(%Message{channel_id: channel_id}), do: channel_id
  def resolve_channel_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a target for a permission overwrite.
  """
  Version.typesince("0.1.1")

  @type overwrite_target_resolvable ::
          Overwrite.t() | Role.t() | User.t() | Member.t() | Crux.Rest.snowflake()

  @doc """
    Resolves a `t:overwrite_target_resolvabe/0` into an overwrite target.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Overwrite{type: "member", id: 218348062828003328}
  ...> |> Crux.Rest.Util.resolve_overwrite_target()
  {"member", 218348062828003328}

  iex> %Crux.Structs.Role{id: 376146940762783746}
  ...> |> Crux.Rest.Util.resolve_overwrite_target()
  {"role", 376146940762783746}

  iex> %Crux.Structs.User{id: 218348062828003328}
  ...> |> Crux.Rest.Util.resolve_overwrite_target()
  {"member", 218348062828003328}

  iex> %Crux.Structs.Member{user: 218348062828003328}
  ...> |> Crux.Rest.Util.resolve_overwrite_target()
  {"member", 218348062828003328}

  iex> 218348062828003328
  ...> |> Crux.Rest.Util.resolve_overwrite_target()
  {:unknown, 218348062828003328}

    ```
  """
  @spec resolve_overwrite_target(overwrite :: overwrite_target_resolvable()) ::
          {String.t() | :unknown, Crux.Rest.snowflake()}
  Version.since("0.1.1")
  def resolve_overwrite_target(%Overwrite{id: id, type: type}), do: {type, id}
  def resolve_overwrite_target(%Role{id: id}), do: {"role", id}
  def resolve_overwrite_target(%User{id: id}), do: {"member", id}
  def resolve_overwrite_target(%Member{user: id}), do: {"member", id}
  def resolve_overwrite_target(id) when is_integer(id), do: {:unknown, id}

  @typedoc """
    All available types that can be resolved into a message id.
  """
  Version.typesince("0.1.1")
  @type message_id_resolvable :: Message.t() | Crux.Rest.snowflake()

  @doc ~S"""
    Resolves a `t:message_id_resolvable/0` into a message id.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Message{id: 441568727302012928}
  ...> |> Crux.Rest.Util.resolve_message_id()
  441568727302012928

  iex> 441568727302012928
  ...> |> Crux.Rest.Util.resolve_message_id()
  441568727302012928

    ```
  """
  @spec resolve_message_id(message :: message_id_resolvable()) :: Crux.Rest.snowflake()
  Version.since("0.1.0")
  def resolve_message_id(%Message{id: id}), do: id
  def resolve_message_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a channel position.
  """
  Version.typesince("0.1.1")

  @type channel_position_resolvable ::
          Channel.t()
          | %{channel: Channel.t(), position: integer()}
          | {Crux.Rest.snowflake(), integer()}
          | %{id: Crux.Rest.snowflake(), position: integer()}

  @doc ~S"""
    Resolves a `t:channel_position_resolvable/0` into a channel position.

  ## Examples

    ```elixir
  iex> %Crux.Structs.Channel{id: 222079895583457280, position: 5}
  ...> |> Crux.Rest.Util.resolve_channel_position()
  %{id: 222079895583457280, position: 5}

  iex> {%Crux.Structs.Channel{id: 222079895583457280}, 5}
  ...> |> Crux.Rest.Util.resolve_channel_position()
  %{id: 222079895583457280, position: 5}

  iex> {222079895583457280, 5}
  ...> |> Crux.Rest.Util.resolve_channel_position()
  %{id: 222079895583457280, position: 5}

  iex> %{id: 222079895583457280, position: 5}
  ...> |> Crux.Rest.Util.resolve_channel_position()
  %{id: 222079895583457280, position: 5}

    ```
  """
  Version.typesince("0.1.1")

  @spec resolve_channel_position(channel :: channel_position_resolvable()) :: %{
          id: Crux.Rest.snowflake(),
          position: integer()
        }
  Version.since("0.1.0")
  def resolve_channel_position({%Channel{id: id}, position}), do: %{id: id, position: position}

  def resolve_channel_position(%{channel: %Channel{id: id}, position: position}),
    do: %{id: id, position: position}

  def resolve_channel_position({id, position}), do: %{id: id, position: position}
  def resolve_channel_position(%{id: id, position: position}), do: %{id: id, position: position}

  @typedoc """
    All available types which can be resolved into a role position.
  """
  Version.typesince("0.1.2")

  @type guild_role_position_resolvable ::
          {Role.t(), integer()}
          | %{id: Crux.Rest.snowflake(), position: integer()}
          | {Crux.Rest.snowflake(), integer()}
          | %{role: Role.t(), position: integer}

  @doc """
    Resolves a `t:guild_role_position_resolvable/0` into a role position.

  ## Examples
    ```elixir
  iex> {%Crux.Structs.Role{id: 373405430589816834}, 5}
  ...> |> Crux.Rest.Util.resolve_guild_role_position()
  %{id: 373405430589816834, position: 5}

  iex> %{id: 373405430589816834, position: 5}
  ...> |> Crux.Rest.Util.resolve_guild_role_position()
  %{id: 373405430589816834, position: 5}

  iex> %{role: %Crux.Structs.Role{id: 373405430589816834}, position: 5}
  ...> |> Crux.Rest.Util.resolve_guild_role_position()
  %{id: 373405430589816834, position: 5}

  iex> {373405430589816834, 5}
  ...> |> Crux.Rest.Util.resolve_guild_role_position()
  %{id: 373405430589816834, position: 5}

    ```
  """
  @spec resolve_guild_role_position(role :: guild_role_position_resolvable()) :: %{
          id: Crux.Rest.snowflake(),
          position: integer()
        }
  Version.typesince("0.1.2")
  def resolve_guild_role_position({%Role{id: id}, position}), do: %{id: id, position: position}

  def resolve_guild_role_position(%{id: id, position: position}),
    do: %{id: id, position: position}

  def resolve_guild_role_position(%{role: %Role{id: id}, position: position}),
    do: %{
      id: id,
      position: position
    }

  def resolve_guild_role_position({id, position}), do: %{id: id, position: position}

  ### End Resolvables
end
