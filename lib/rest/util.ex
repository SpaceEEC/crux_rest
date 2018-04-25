defmodule Crux.Rest.Util do
  @moduledoc """
    Collection of util functions.
  """
  
  alias Crux.Structs.{Channel, Emoji, Member, Message, Overwrite, Reaction, Role, User}

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

      String.valid?(file) ->
        File.read(file)

      is_binary(file) ->
        {:ok, file}

      true ->
        {:error, :no_binary}
    end
  end

  @typedoc """
    Used when sending files via `Rest.create_message/2`.
  """
  @type resolved_file ::
          {
            String.t() | :file,
            String.t() | binary(),
            {String.t(), [{String.t(), binary()}]},
            [{String.t(), String.t()}]
          }
          | {:error, term()}

  @doc """
    Resolves a:
    * path to a file
    * tuple of path to a file or binary of one, and a file name
    to a `resolved_file` automatically used by `Rest.create_message/2`
  """
  # path
  @spec map_file(
          path ::
            String.t()
            | {String.t() | binary(), String.t()}
            | {String.t() | :file, String.t() | binary(), String.t()}
        ) :: resolved_file() | {:error, term()}
  def(map_file(path) when is_bitstring(path), do: map_file({path, Path.basename(path)}))
  # {binary | path, name}
  def map_file({bin_or_path, name}) when is_binary(bin_or_path) do
    cond do
      Regex.match?(~r{^https?://}, bin_or_path) ->
        with {:ok, %{body: file}} <- HTTPoison.get(bin_or_path) do
          map_file({Path.basename(name, file), Path.basename(name)})
        else
          {:error, inner} ->
            {:error, inner}

          other ->
            {:error, other}
        end

      # Not sure whether this is actually a good idea
      String.valid?(bin_or_path) ->
        map_file({:file, bin_or_path, Path.basename(name)})

      true ->
        map_file({Path.basename(name), bin_or_path, Path.basename(name)})
    end
  end

  def map_file({name_or_atom, bin_or_path, name}) do
    disposition = {"form-data", [{"filename", "\"#{name}\""}]}
    headers = [{"content-type", :mimerl.filename(name)}]

    {name_or_atom, bin_or_path, disposition, headers}
  end

  @spec resolve_role_id(role :: Role.t() | integer()) :: integer()
  def resolve_role_id(%Role{id: role_id}), do: role_id
  def resolve_role_id(role_id) when is_number(role_id), do: role_id

  # reaction
  @spec resolve_emoji_identifier(emoji :: Reaction.t() | Emoji.t() | String.t()) :: String.t()
  def resolve_emoji_identifier(%Reaction{emoji: emoji}), do: resolve_emoji_identifier(emoji)
  # default emoji
  def resolve_emoji_identifier(%Emoji{id: nil, name: name}), do: name
  # custom animated emoji
  def resolve_emoji_identifier(%Emoji{animated: true, id: id, name: name}), do: "a:#{name}:#{id}"
  # custom emoji
  def resolve_emoji_identifier(%Emoji{id: id, name: name}), do: "#{name}:#{id}"
  # unicode, or at least we assume that here
  def resolve_emoji_identifier(emoji) when is_bitstring(emoji), do: emoji
  def resolve_emoji_identifier(emoji), do: {:error, {:unknown_identifier, emoji}}

  @spec resolve_user_id(user :: User.t() | Member.t() | integer()) :: integer()
  def resolve_user_id(%User{id: id}), do: id
  def resolve_user_id(%Member{user: %User{id: id}}), do: id
  def resolve_user_id(id) when is_number(id), do: id

  @spec resolve_overwrite_target(
          overwrite :: Overwrite.t() | Role.t() | User.t() | Member.t() | integer()
        ) :: {:role | :member | :unknown, integer()}
  def resolve_overwrite_target(%Overwrite{id: id, type: type}), do: {type, id}
  def resolve_overwrite_target(%Role{id: id}), do: {:role, id}
  def resolve_overwrite_target(%User{id: id}), do: {:member, id}
  def resolve_overwrite_target(%Member{user: %User{id: id}}), do: {:member, id}
  def resolve_overwrite_target(id) when is_integer(id), do: {:unknown, id}
  def resolve_overwrite_target(_), do: :error

  @spec resolve_message_id(message :: Message.t() | integer()) :: integer()
  def resolve_message_id(%Message{id: id}), do: id
  def resolve_message_id(id) when is_number(id), do: id

  @spec resolve_channel_position(
          channel ::
            Channel.t() | map() | {integer(), integer() | %{id: integer(), position: integer()}}
        ) :: %{id: integer(), position: integer()}
  def resolve_channel_position({%Channel{id: id}, position}), do: %{id: id, position: position}

  def resolve_channel_position(%{channel: %Channel{id: id}, position: position}),
    do: %{id: id, position: position}

  def resolve_channel_position({id, position}), do: %{id: id, position: position}
  def resolve_channel_position(%{id: id, position: position}), do: %{id: id, position: position}
end
