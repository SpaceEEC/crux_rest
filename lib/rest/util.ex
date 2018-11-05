defmodule Crux.Rest.Util do
  @moduledoc """
    Collection of util functions.
  """

  alias Crux.Structs.{Channel, Emoji, Guild, Member, Message, Overwrite, Reaction, Role, User}

  @doc """
    Resolves a string or a binary to a `t:binary/0`.
    * http / https url
    * local file path
    * a binary itself
  """
  @spec resolve_file(file :: String.t() | binary()) :: {:ok, binary()} | {:error, term()}
  def resolve_file(nil), do: nil

  def resolve_file(file) do
    cond do
      Regex.match?(~r{^https?://}, file) ->
        with {:ok, response} <- HTTPoison.get(file) do
          {:ok, response.body}
        end

      File.exists?(file) && File.stat!(file).type == :regular ->
        File.read(file)

      is_binary(file) ->
        {:ok, file}

      true ->
        {:error, :no_binary}
    end
  end

  @doc """
    Resolves and encodes a file resolvable under a key in a map.
    If the key is not in the map nothing is done.
  """
  @spec encode_map_key(map(), atom()) :: map()
  def encode_map_key(%{} = map, key) when is_atom(key) do
    case map do
      %{^key => file} when not is_nil(file) ->
        with {:ok, binary} <- resolve_file(file) do
          Map.put(map, key, "data:image/jpg;base64,#{Base.encode64(binary)}")
        end

      _ ->
        map
    end
  end

  @typedoc """
    Used when sending files via `Rest.create_message/2`.

    The elements are:
    1. Name of the file or :file for a local file
    2. Binary of the file or the file path
    3. Disposition (for form-data)
    4. Headers (content-type)
  """
  @type resolved_file ::
          {
            String.t() | :file,
            binary() | String.t(),
            {String.t(), [{String.t(), binary()}]},
            [{String.t(), String.t()}]
          }
          | {:error, term()}

  @doc """
    Resolves a:
    * path to a file
    * tuple of path to a file or binary of one, and a file name
    to a `t:resolved_file/0` automatically used by `Rest.create_message/2`
  """
  @spec map_file(
          path ::
            Crux.Rest.file_list_entry()
            | {String.t() | :file, String.t() | binary(), String.t()}
        ) :: resolved_file() | {:error, term()}
  # path
  def map_file(path) when is_binary(path) do
    map_file({Path.basename(path), path, Path.basename(path)})
  end

  # {binary | path, name}
  def map_file({bin_or_path, name})
      when is_bitstring(bin_or_path) and is_binary(name) do
    cond do
      Regex.match?(~r{^https?://}, bin_or_path) ->
        with {:ok, %{body: file}} <- HTTPoison.get(bin_or_path) do
          map_file({Path.basename(name), file, Path.basename(name)})
        else
          {:error, _error} = error ->
            error

          other ->
            {:error, other}
        end

      File.exists?(bin_or_path) ->
        with {:ok, %{type: :regular}} <- File.stat(bin_or_path) do
          map_file({:file, bin_or_path, Path.basename(name)})
        else
          {:error, _error} = error ->
            error

          other ->
            {:error, other}
        end

      true ->
        map_file({Path.basename(name), bin_or_path, Path.basename(name)})
    end
  end

  def map_file({name_or_atom, bin_or_path, name})
      when (is_binary(name_or_atom) or name_or_atom == :file) and is_bitstring(bin_or_path) and
             is_binary(name) do
    disposition = {"form-data", [{"filename", "\"#{name}\""}, {"name", "\"#{name}\""}]}
    headers = [{"content-type", :mimerl.filename(name)}]

    {name_or_atom, bin_or_path, disposition, headers}
  end

  @typedoc """
    All available types that can be resolved into a role id.
  """
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
  def resolve_role_id(%Role{id: role_id}), do: role_id
  def resolve_role_id(role_id) when is_number(role_id), do: role_id

  @typedoc """
    All available types that can be resolved into an emoji identifier.
  """
  @type emoji_identifier_resolvable :: Reaction.t() | Emoji.t() | String.t()

  @typedoc """
    All available types that can be resolved into an emoji id.
  """
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
  def resolve_emoji_id(%Emoji{id: id}) when not is_nil(id), do: id
  def resolve_emoji_id(%Reaction{emoji: emoji}), do: resolve_emoji_id(emoji)
  def resolve_emoji_id(emoji) when is_integer(emoji), do: emoji

  @typedoc """
    All available types that can be resolved into a user id.
  """
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
  def resolve_user_id(%User{id: id}), do: id
  def resolve_user_id(%Member{user: id}), do: id
  def resolve_user_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a guild id.
  """
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
  def resolve_guild_id(%Guild{id: id}), do: id
  def resolve_guild_id(%Channel{guild_id: id}) when not is_nil(id), do: id
  def resolve_guild_id(%Message{guild_id: id}) when not is_nil(id), do: id
  def resolve_guild_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a channel id.
  """
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
  def resolve_channel_id(%Channel{id: id}), do: id
  def resolve_channel_id(%Message{channel_id: channel_id}), do: channel_id
  def resolve_channel_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a target for a permission overwrite.
  """
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
  def resolve_overwrite_target(%Overwrite{id: id, type: type}), do: {type, id}
  def resolve_overwrite_target(%Role{id: id}), do: {"role", id}
  def resolve_overwrite_target(%User{id: id}), do: {"member", id}
  def resolve_overwrite_target(%Member{user: id}), do: {"member", id}
  def resolve_overwrite_target(id) when is_integer(id), do: {:unknown, id}

  @typedoc """
    All available types that can be resolved into a message id.
  """
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
  def resolve_message_id(%Message{id: id}), do: id
  def resolve_message_id(id) when is_number(id), do: id

  @typedoc """
    All available types that can be resolved into a channel position.
  """
  @type channel_position_resolvable ::
          Channel.t()
          | %{channel: Channel.t(), position: integer()}
          | {Crux.Rest.snowflake(), integer()}
          | %{id: Crux.Rest.snowflake(), position: integer()} :: %{
            id: Crux.Rest.snowflake(),
            position: integer()
          }

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
  @spec resolve_channel_position(channel :: channel_position_resolvable()) :: %{
          id: Crux.Rest.snowflake(),
          position: integer()
        }
  def resolve_channel_position({%Channel{id: id}, position}), do: %{id: id, position: position}

  def resolve_channel_position(%{channel: %Channel{id: id}, position: position}),
    do: %{id: id, position: position}

  def resolve_channel_position({id, position}), do: %{id: id, position: position}
  def resolve_channel_position(%{id: id, position: position}), do: %{id: id, position: position}

  @typedoc """
    All available types which can be resolved into a role position.
  """
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
  def resolve_guild_role_position({%Role{id: id}, position}), do: %{id: id, position: position}

  def resolve_guild_role_position(%{id: id, position: position}),
    do: %{id: id, position: position}

  def resolve_guild_role_position(%{role: %Role{id: id}, position: position}),
    do: %{
      id: id,
      position: position
    }

  def resolve_guild_role_position({id, position}), do: %{id: id, position: position}
end
