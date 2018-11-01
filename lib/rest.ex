defmodule Crux.Rest do
  @moduledoc """
    Collection of Rest functions.
  """
  alias Crux.Structs

  alias Crux.Structs.{
    AuditLog,
    Channel,
    Emoji,
    Guild,
    Invite,
    Member,
    Message,
    Role,
    User,
    Webhook
  }

  alias Crux.Rest
  alias Crux.Rest.{Endpoints, Util}

  use Crux.Rest.Bang

  defp create(:ok, _to), do: :ok
  defp create({:ok, res}, to), do: {:ok, Structs.create(res, to)}
  defp create({:error, _} = res, _to), do: res

  ### Message
  @typedoc """
    A Discord snowflake, fits in a 64bit integer.

    Received as integers via the gateway, but as strings via http.

  > They are normalized to integers via `Crux.Structs`.
  """
  @type snowflake :: non_neg_integer()

  @typedoc """
    Used to attach files via `create_message/2`.

    This can be one of:

    |                  | Example                                                  |
    | `path`           | `/home/user/image.png` / `https://example.com/image.png` |
    | `{path, name}`   | `{one of the above, "other_name.png"}`                   |
    | `{binary, name}` | `{<<0, 0, 0, 0>>, "other_name.png"}`                     |
  """
  @type file_list_entry :: String.t() | {String.t(), String.t()}

  @typedoc """
    Used to send messages via `create_message/2`.

    The content my not exceed 2000 chars.
    The nonce has to fit in a 64 bit integer.
    The whole message payload may not be larger than 8mb, this should only be possible when attaching (a) large file(s).
  """
  @type create_message_data ::
          %{
            optional(:content) => String.t(),
            optional(:nonce) => non_neg_integer(),
            optional(:tts) => boolean(),
            optional(:embed) => embed(),
            optional(:files) => [file_list_entry()]
          }
          | [
              {:content, String.t()}
              | {:nonce, non_neg_integer()}
              | {:tts, boolean()}
              | {:embed, embed()}
              | {:files, [file_list_entry()]}
            ]

  @typedoc """
    Used to send and embed via `create_message/2`.

    You should probably consult the [Embed Limits](https://discordapp.com/developers/docs/resources/channel#embed-limits) page.
  """
  @type embed :: %{
          optional(:title) => String.t(),
          optional(:description) => String.t(),
          optional(:url) => String.t(),
          optional(:timestamp) => String.t(),
          optional(:color) => non_neg_integer(),
          optional(:footer) => %{
            optional(:text) => String.t(),
            optional(:icon_url) => String.t()
          },
          optional(:image) => %{
            optional(:url) => String.t()
          },
          optional(:thumbnail) => %{
            optional(:url) => String.t()
          },
          optional(:author) => %{
            optional(:name) => String.t(),
            optional(:url) => String.t(),
            optional(:icon_url) => String.t()
          },
          optional(:fields) => [
            %{
              required(:name) => String.t(),
              required(:value) => String.t(),
              optional(:inline) => boolean()
            }
          ]
        }

  @doc """
    Sends a message to a channel.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-message)
  """
  @spec create_message(
          channel :: Util.channel_id_resolvable(),
          args :: create_message_data()
        ) :: {:ok, Message.t()} | {:error, term()}
  def create_message(channel_or_message, args)
  def create_message(%Message{channel_id: channel_id}, args), do: create_message(channel_id, args)
  def create_message(%Channel{id: channel_id}, args), do: create_message(channel_id, args)

  def create_message(channel_id, not_map) when not is_map(not_map),
    do: create_message(channel_id, Map.new(not_map))

  def create_message(channel_id, %{files: files} = args) when is_number(channel_id) do
    Enum.reduce_while(files, [], fn file, acc ->
      with {:error, error} <- Util.map_file(file) do
        {:halt, error}
      else
        tuple ->
          {:cont, [tuple | acc]}
      end
    end)
    |> case do
      form_data when is_list(form_data) ->
        args = Map.delete(args, :files)

        form_data =
          if Map.has_key?(args, :embed) || Map.has_key?(args, :content),
            do: [{"payload_json", Poison.encode!(args)} | form_data],
            else: form_data

        real_create_message(channel_id, {:multipart, form_data}, [
          {"content-type", "multipart/form-data"}
        ])

      {:error, _error} = error ->
        error
    end
  end

  def create_message(channel_id, args), do: real_create_message(channel_id, args)

  defp real_create_message(channel_id, args, disposition \\ []) do
    Rest.Base.queue(:post, Endpoints.channel_messages(channel_id), args, disposition)
    |> create(Message)
  end

  @typedoc """
    Used to edit messages via `edit_message/2` or `edit_message/3`.

    The content my not exceed 2000 chars, this limit is enfored on discord's end.
  """
  @type message_edit_data ::
          %{
            optional(:content) => String.t() | nil,
            optional(:embed) => embed() | nil
          }
          | [{:content, String.t()} | {:embed, embed()}]

  @doc """
  Edits a message.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#edit-message).
  """
  @spec edit_message(
          target :: Message.t(),
          args :: message_edit_data()
        ) :: {:ok, Message.t()} | {:error, term()}
  def edit_message(message, args)

  def edit_message(%Message{channel_id: channel_id, id: message_id}, args),
    do: edit_message(channel_id, message_id, args)

  @doc """
  Edits a message.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#edit-message).
  """
  def edit_message(channel, message_id, args)

  @spec edit_message(
          channel_id :: Util.channel_id_resolvable(),
          message_id :: Util.message_id_resolvable(),
          args :: message_edit_data()
        ) :: {:ok, Message.t()} | {:error, term()}
  def edit_message(channel, message, args) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    body = Map.new(args)

    Rest.Base.queue(:patch, Endpoints.channel_messages(channel_id, message_id), body)
    |> create(Message)
  end

  @doc """
    Deletes a message

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-message).
  """
  @spec delete_message(message :: Message.t()) :: {:ok, Message.t()} | {:error, term()}
  def delete_message(message)

  def delete_message(%Message{channel_id: channel_id, id: message_id}),
    do: delete_message(channel_id, message_id)

  @doc """
    Deletes a message

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-message).
  """
  @spec delete_message(
          channel_id :: Util.channel_id_resolvable(),
          message_id :: Util.message_id_resolvable()
        ) :: {:ok, Message} | {:error, term()}
  def delete_message(channel, message) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    Rest.Base.queue(:delete, Endpoints.channel_messages(channel_id, message_id))
  end

  @doc """
    Deletes 2-100 messages not older than 14 days.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages)
  """
  @spec delete_messages(
          channel :: Util.channel_id_resolvable(),
          messages :: [Util.message_id_resolvable()]
        ) :: :ok | {:error, term()}
  def delete_messages(channel, messages) do
    channel_id = Util.resolve_channel_id(channel)
    messages = Enum.map(messages, &Util.resolve_message_id/1)

    Rest.Base.queue(:post, Endpoints.channel_messages(channel_id, "bulk-delete"), %{
      messages: messages
    })
  end

  @doc """
    Gets a message from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel-message).
  """
  @spec get_message(
          channel :: Util.channel_id_resolvable(),
          message_id :: Util.message_id_resolvable()
        ) :: {:ok, Message} | {:error, term()}
  def get_message(channel, message) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    Rest.Base.queue(:get, Endpoints.channel_messages(channel_id, message_id))
    |> create(Message)
  end

  @typedoc """
    Used to get messages from the api via `get_messages/2`.

    Notes:
  * `:around` is inclusive
  * `:before` and `:after` are exclusive
  * `:limit` has to be [1-100], defaults to 50
  """
  @type get_messages_data ::
          %{
            optional(:around) => snowflake(),
            optional(:before) => snowflake(),
            optional(:after) => snowflake(),
            optional(:limit) => pos_integer()
          }
          | [
              {:around, snowflake()}
              | {:before, snowflake()}
              | {:after, snowflake()}
              | {:limit, pos_integer()}
            ]

  @doc """
  Gets 1-100 messages from the api, this limit is enforced on discord's end.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel-messages).
  """
  @spec get_messages(
          channel :: Util.channel_id_resolvable(),
          args :: get_messages_data()
        ) :: {:ok, [Message.t()]} | {:error, term()}

  def get_messages(channel, args \\ []) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:get, Endpoints.channel_messages(channel_id), "", [], params: args)
    |> create(Message)
  end

  ### End Message

  ### Reaction

  @doc """
  Creates a reaction on a message, or increases its count by one.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-reaction).
  """
  @spec create_reaction(
          message :: Util.message_id_resolvable(),
          emoji :: Util.emoji_identifier_resolvable()
        ) :: :ok | {:error, term()}

  def create_reaction(%Message{channel_id: channel_id, id: message_id}, emoji),
    do: create_reaction(channel_id, message_id, emoji)

  @doc """
  Creates a reaction on a message, or increases its count by one.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-reaction).
  """
  @spec create_reaction(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable(),
          emoji :: Util.emoji_id_resolvable()
        ) :: :ok | {:error, term()}
  def create_reaction(channel, message, emoji) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    emoji =
      emoji
      |> Emoji.to_identifier()
      |> URI.encode_www_form()

    Rest.Base.queue(:put, Endpoints.message_reactions(channel_id, message_id, emoji, "@me"))
  end

  @typedoc """
    Used to get more specific users who reacted to a message from the api via `get_reactions/4`

    Notes:
    * `:before` seems currently broken on discord's end
    * `:after` is exclusive
  """
  @type get_reactions_data ::
          %{
            optional(:before) => snowflake(),
            optional(:after) => snowflake(),
            optional(:limit) => pos_integer()
          }
          | [
              {:before, snowflake()}
              | {:after, snowflake()}
              | {:limit, pos_integer()}
            ]

  @doc """
    Gets users who reacted to a message.

    The first argument is optional if a `Crux.Structs.Message` is provided.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-reactions).
  """
  @spec get_reactions(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable(),
          emoji :: Util.emoji_identifier_resolvable(),
          args :: get_reactions_data()
        ) :: {:ok, [User.t()]} | {:error, term()}
  def get_reactions(
        channel_or_message,
        emoji_or_message_id,
        emoji_or_maybe_data \\ [],
        maybe_data \\ []
      )

  @spec get_reactions(
          message :: Message.t(),
          emoji :: Util.emoji_identifier_resolvable(),
          args :: get_reactions_data()
        ) :: {:ok, [User.t()]} | {:error, term()}
  def get_reactions(%Message{channel_id: channel_id, id: message_id}, emoji, args, _),
    do: get_reactions(channel_id, message_id, emoji, args)

  def get_reactions(channel, message, emoji, args) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    emoji =
      emoji
      |> Emoji.to_identifier()
      |> URI.encode_www_form()

    Rest.Base.queue(
      :get,
      Endpoints.message_reactions(channel_id, message_id, emoji),
      "",
      [],
      params: args
    )
    |> create(User)
  end

  @doc """
    Deletes a user from a reaction.

    The first argument is optional if a `Crux.Structs.Message` is provided.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-own-reaction) [2](https://discordapp.com/developers/docs/resources/channel#delete-user-reaction).
  """
  @spec delete_reaction(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable(),
          emoji :: Util.emoji_identifier_resolvable(),
          user :: Util.user_id_resolvable()
        ) :: :ok | {:error, term()}
  def delete_reaction(
        message_or_channel,
        emoji_or_message_id,
        emoji_or_maybe_user \\ "@me",
        mayber_user \\ "@me"
      )

  def delete_reaction(%Message{channel_id: channel_id, id: message_id}, emoji, user, _),
    do: delete_reaction(channel_id, message_id, emoji, user)

  def delete_reaction(channel, message, emoji, user) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    emoji =
      emoji
      |> Emoji.to_identifier()
      |> URI.encode_www_form()

    user = Util.resolve_user_id(user)

    Rest.Base.queue(:delete, Endpoints.message_reactions(channel_id, message_id, emoji, user))
  end

  @doc """
    Deletes all reactions from a messaage.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-all-reactions).
  """
  @spec delete_all_reactions(
          message :: Message.t(),
          emoji :: Util.emoji_identifier_resolvable()
        ) :: :ok | {:error, term()}
  def delete_all_reactions(message, emoji)

  def delete_all_reactions(%Message{channel_id: channel_id, id: message_id}, emoji),
    do: delete_all_reactions(channel_id, message_id, emoji)

  @doc """
    Deletes all reactions from a messaage.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-all-reactions).
  """
  @spec delete_all_reactions(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable(),
          emoji :: Util.emoji_identifier_resolvable()
        ) :: :ok | {:error, term()}
  def delete_all_reactions(channel, message, emoji) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    emoji =
      emoji
      |> Emoji.to_identifier()
      |> URI.encode_www_form()

    Rest.Base.queue(:delete, Endpoints.message_reactions(channel_id, message_id, emoji))
  end

  ### End Reactions

  ### Channel

  @doc """
    Lets the bot appear as typing for roughly ~9 seconds or until a message is sent.
    Should generally be used sparingly for commands that may take a while as a form of acknowledging.

    Consider sending a message and edit that later on instead.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#trigger-typing-indicator).
  """
  @spec trigger_typing(channel :: Util.channel_id_resolvable()) :: :ok | {:error, term()}
  def trigger_typing(channel) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:post, Endpoints.channel(channel_id, "typing"))
  end

  @doc """
    Adds a message to the pinned messages of a channel.

    You may only have up to 50 pinned messages per channel.
    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message).
  """
  @spec add_pinned_message(message :: Message.t()) :: :ok | {:error, term()}
  def add_pinned_message(message)

  def add_pinned_message(%Message{channel_id: channel_id, id: message_id}),
    do: add_pinned_message(channel_id, message_id)

  @doc """
    Adds a message to the pinned messages of a channel.

    You may only have up to 50 pinned messages per channel.
    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message).
  """
  @spec add_pinned_message(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable()
        ) :: :ok | {:error, term()}
  def add_pinned_message(channel, message) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    Rest.Base.queue(:put, Endpoints.channel_pins(channel_id, message_id))
  end

  @doc """
    Deletes a message from the pinned messages. This does not delete the message itself.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message).
  """
  @spec delete_pinned_message(message :: Message.t()) :: :ok | {:error, term()}
  def delete_pinned_message(message)

  def delete_pinned_message(%Message{channel_id: channel_id, id: message_id}),
    do: delete_pinned_message(channel_id, message_id)

  @doc """
    Deletes a message from the pinned messages. This does not delete the message itself.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message).
  """
  @spec delete_pinned_message(
          channel :: Util.channel_id_resolvable(),
          message :: Util.message_id_resolvable()
        ) :: :ok | {:error, term()}

  def delete_pinned_message(channel, message) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    Rest.Base.queue(:delete, Endpoints.channel_pins(channel_id, message_id))
  end

  @doc """
    Gets a channel from the api.
    This should _NOT_ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel)
  """
  @spec get_channel(channel :: Util.resolve_channel_id()) :: {:ok, Channel.t()} | {:error, term()}
  def get_channel(channel) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:get, Endpoints.channel(channel_id))
    |> create(Channel)
  end

  @typedoc """
    Used to modify a channel via `modify_channel/2`.

    Notes
  * `:name` has to be [2-100] chars long.
  * `:topic` has to be [0-1024] chars long
  * `:bitrate` is in bits [8_000-96_000] (128_000 for VIP servers)
  * `:user_limit` has to be [0-99], 0 refers to no limit
  * `:rate_limit_per_user` has to be [0-120], 0 refers to no limit

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#modify-channel-json-params).
  """
  @type modify_channel_data ::
          %{
            optional(:bitrate) => non_neg_integer(),
            optional(:icon) => String.t() | binary() | nil,
            optional(:name) => String.t() | nil,
            optional(:nsfw) => boolean(),
            optional(:parent_id) => snowflake() | nil,
            optional(:permission_overwrites) => [Overwrite.t()],
            optional(:position) => non_neg_integer(),
            optional(:rate_limit_per_user) => non_neg_integer(),
            optional(:reason) => String.t(),
            optional(:topic) => String.t() | nil,
            optional(:user_limit) => non_neg_integer() | nil
          }
          | [
              {:bitrate, non_neg_integer()}
              | {:icon, String.t() | binary() | nil}
              | {:name, String.t() | nil}
              | {:nsfw, boolean()}
              | {:parent_id, snowflake() | nil}
              | {:permission_overwrites, [Overwrite.t()]}
              | {:position, non_neg_integer()}
              | {:rate_limit_per_user, non_neg_integer()}
              | {:reason, String.t()}
              | {:topic, String.t() | nil}
              | {:user_limit, integer() | nil}
            ]

  @doc """
    Modifies a channel, see `t:modify_channel_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#modify-channel).
  """
  @spec modify_channel(
          channel :: Util.channel_id_resolvable(),
          args :: modify_channel_data()
        ) :: {:ok, Channel.t()} | {:error, term()}
  def modify_channel(channel, args) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:patch, Endpoints.channel(channel_id), Map.new(args))
    |> create(Channel)
  end

  @doc """
    Deletes a channel.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#deleteclose-channel).
  """
  @spec delete_channel(
          channel :: Util.channel_id_resolvable(),
          reason :: String.t()
        ) :: {:ok, Channel.t()} | {:error, term()}

  def delete_channel(channel, reason \\ nil) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:delete, Endpoints.channel(channel_id), %{reason: reason})
    |> create(Channel)
  end

  @typedoc """
    Used to edit overwrites for a role or member with `edit_channel_permissions/3`

    See [Permissions](https://discordapp.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags) for available bitflags.
  """
  @type edit_channel_permissions_data ::
          %{
            optional(:allow) => non_neg_integer(),
            optional(:deny) => non_neg_integer(),
            optional(:type) => String.t(),
            optional(:reason) => String.t()
          }
          | {{:allow, non_neg_integer()}
             | {:deny, non_neg_integer()}
             | {:type, :member | :role | String.t()}
             | {:reason, String.t()}}

  @doc """
  Edits or creates an overwrite for a user, or member.

  If an id is provided for `:target`, `:type` must be specified in `t:edit_channel_permissions_data`.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions).
  """
  @spec edit_channel_permissions(
          channel :: Util.channel_id_resolvable(),
          target :: Util.overwrite_target_resolvable(),
          data :: edit_channel_permissions_data()
        ) :: :ok | {:error, :missing_target} | {:error, term()}
  def edit_channel_permissions(channel, target, data)

  def edit_channel_permissions(channel, target, data) when is_map(target) do
    channel_id = Util.resolve_channel_id(channel)

    {type, target_id} = Util.resolve_overwrite_target(target)

    if type != :unknown || data[:type] do
      data =
        data
        |> Map.new()
        |> Map.put_new(:type, type)

      edit_channel_permissions(channel_id, target_id, data)
    else
      {:error, :missing_target}
    end
  end

  def edit_channel_permissions(channel_id, target_id, data) do
    if data[:type] do
      Rest.Base.queue(:put, Endpoints.channel_permissions(channel_id, target_id), Map.new(data))
    else
      {:error, :missing_target}
    end
  end

  @doc """
    Gets invites for the specified channel from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel-invites)
  """
  @spec get_channel_invites(channel :: Util.channel_id_resolvable()) ::
          {:ok, [Invite.t()]} | {:error, term()}
  def get_channel_invites(channel) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:get, Endpoints.channel(channel_id, "invites"))
    |> create(Invite)
  end

  @typedoc """
    Used to create invites via `create_channel_invite/2`.

    Notes:
    * `:max_age` 0 indicates no max age, defaults to 86_400 (1 day)
    * `:max_uses` 0 indicates no max uses, defaults to 0
    * `:temporary` if true, members which do not get a role assigned within 24 hours get automatically kicked, defaults to false
    * `:unique` if true, always creates a new invite instead of maybe returning a similar one, defaults to false

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-channel-invite-json-params).
  """
  @type create_channel_invite_data ::
          %{
            optional(:max_age) => non_neg_integer(),
            optional(:max_uses) => non_neg_integer(),
            optional(:temporary) => boolean(),
            optional(:unique) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:max_age, non_neg_integer()}
              | {:max_uses, non_neg_integer()}
              | {:temporary, boolean()}
              | {:unique, boolean()}
              | {:reason, String.t()}
            ]

  @doc """
    Creates an invite to a channel, see `t:create_channel_invite_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
  """
  @spec create_channel_invite(
          channel :: Util.channel_id_resolvable(),
          args :: create_channel_invite_data()
        ) :: {:ok, Invite.t()} | {:error, term()}
  def create_channel_invite(channel, args) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:post, Endpoints.channel(channel_id, "invites"), Map.new(args))
    |> create(Invite)
  end

  @doc """
    Deletes an overwrite from a channel.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-channel-permission).
  """
  @spec delete_channel_permissions(
          channel :: Util.channel_id_resolvable(),
          target :: Util.overwrite_target_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def delete_channel_permissions(channel, target, reason \\ nil) do
    channel_id = Util.resolve_channel_id(channel)
    {_type, target_id} = Util.resolve_overwrite_target(target)

    Rest.Base.queue(:delete, Endpoints.channel_permissions(channel_id, target_id), %{
      reason: reason
    })
  end

  @doc """
    Gets a list of pinned messages from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-pinned-messages).
  """
  @spec get_pinned_messages(channel :: Util.channel_id_resolvable()) ::
          {:ok, [Message.t()]} | {:error, term()}
  def get_pinned_messages(channel) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:get, Endpoints.channel(channel_id, "pins"))
    |> create(Message)
  end

  ### End Channel

  ### Emoji

  @doc """
    Gets a list of emojis in a guild.
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#list-guild-emojis).
  """
  @spec list_guild_emojis(guild :: Util.guild_id_resolvable()) ::
          {:ok, [Emoji.t()]} | {:error, term()}
  def list_guild_emojis(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_emojis(guild_id))
    |> create(Emoji)
  end

  @doc """
    Gets an emoji from a guild
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#get-guild-emoji).
  """
  @spec get_guild_emoji(
          guild :: Util.guild_id_resolvable(),
          emoji :: Util.emoji_id_resolvable()
        ) :: {:ok, Emoji} | {:error, term()}
  def get_guild_emoji(guild, emoji) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    Rest.Base.queue(:get, Endpoints.guild_emojis(guild_id, emoji_id))
    |> create(Emoji)
  end

  @typedoc """
    Used to create emojis via `create_guild_emoji/2`.

    Notes:
    * `:name` has to be [1-32] chars long, valid chars are [a-Z_0-9] (invalid chars may get filtered out instead of erroring).
        A 1 char long name gets suffixed with `_` to be 2 chars long.
    * `:image` may not be larger than 256kb
    * `:roles`, if present limits the emoji to only those roles
  """
  @type create_guild_emoji_data ::
          %{
            required(:name) => String.t(),
            required(:image) => String.t() | binary(),
            optional(:roles) => [Role.t() | snowflake()],
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:image, String.t() | binary()}
              | {:roles, [Role.t() | snowflake()]}
              | {:reason, String.t()}
            ]

  @doc """
    Creates an emoji in a guild, see `t:create_guild_emoji_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#create-guild-emoji).
  """
  @spec create_guild_emoji(
          guild :: Util.guild_id_resolvable(),
          data :: create_guild_emoji_data()
        ) :: {:ok, Emoji} | {:error, term}
  def create_guild_emoji(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    data
    |> Map.new()
    |> Map.update!(:image, fn image ->
      with {:ok, binary} <- Util.resolve_file(image), do: binary
    end)
    |> Map.update(:roles, [], &Enum.map(&1, fn role -> Util.resolve_role_id(role) end))
    |> case do
      %{image: {:error, error}} ->
        {:error, error}

      data ->
        Rest.Base.queue(:post, Endpoints.guild_emojis(guild_id), data)
        |> create(Emoji)
    end
  end

  @typedoc """
   Used to modify a guild emoji via `modify_guild_emoji/3`.

   See `t:create_guild_emoji_data` for name restrictions.
  """
  @type modify_guild_emoji_data ::
          %{
            optional(:name) => String.t(),
            optional(:roles) => [Role.t() | snowflake()],
            optional(:reason) => String.t()
          } :: [
            {:name, String.t()}
            | {:roles, [Role.t() | snowflake]}
            | {:reason, String.t()}
          ]

  @doc """
    Modifies a guild emoji.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji).
  """
  @spec modify_guild_emoji(
          guild :: Util.guild_id_resolvable(),
          emoji :: Util.emoji_id_resolvable(),
          data :: modify_guild_emoji_data()
        ) :: {:ok, Emoji} | {:error, term()}
  def modify_guild_emoji(guild, emoji, data) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    case Map.new(data) do
      %{roles: roles} ->
        Map.put(data, :roles, Enum.map(roles, &Util.resolve_role_id/1))

      _ ->
        data
    end

    Rest.Base.queue(:patch, Endpoints.guild_emojis(guild_id, emoji_id), data)
    |> create(Emoji)
  end

  @doc """
    Deletes an emoji from a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#delete-guild-emoji).
  """
  @spec delete_guild_emoji(
          guild :: Util.guild_id_resolvable(),
          emoji :: Util.emoji_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def delete_guild_emoji(guild, emoji, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    Rest.Base.queue(:delete, Endpoints.guild_emojis(guild_id, emoji_id), %{reason: reason})
  end

  ### End Emoji

  ### Guild

  # @doc, maybe later
  # @spec, yeah no
  # https://discordapp.com/developers/docs/resources/guild#create-guild
  # ^ worth a read if planing to be used
  def create_guild(data) do
    data =
      data
      |> Map.new()
      |> Map.update(:icon, nil, fn icon ->
        if icon, do: with({:ok, binary} <- Util.resolve_file(icon), do: binary |> Base.encode64())
      end)

    Rest.Base.queue(:post, Endpoints.guild(), data)
    |> create(Guild)
  end

  @doc """
    Gets a guild from the api.
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild)
  """
  @spec get_guild(guild :: Util.guild_id_resolvable()) :: {:ok, Guild.t()} | {:error, term()}
  def get_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild(guild_id))
    |> create(Guild)
  end

  @typedoc """
    TBD, see `modify_guild/2`
  """
  @type modify_guild_data ::
          %{
            optional(:name) => String.t(),
            optional(:region) => String.t(),
            optional(:verification_level) => non_neg_integer(),
            optional(:default_message_notifications) => non_neg_integer(),
            optional(:explicit_content_filter) => non_neg_integer(),
            optional(:afk_channel_id) => snowflake() | nil,
            optional(:afk_timeout) => non_neg_integer(),
            optional(:icon) => String.t() | binary() | nil,
            optional(:splash) => String.t() | binary() | nil,
            optional(:owner_id) => snowflake(),
            optional(:system_channel_id) => snowflake() | nil,
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:region, String.t()}
              | {:verification_level, non_neg_integer()}
              | {:default_message_notifications, non_neg_integer()}
              | {:explicit_content_filter, non_neg_integer()}
              | {:afk_channel_id, snowflake() | nil}
              | {:afk_timeout, non_neg_integer()}
              | {:icon, String.t() | binary() | nil}
              | {:splash, String.t() | binary() | nil}
              | {:owner_id, snowflake()}
              | {:system_channel_id, snowflake() | nil}
              | {:reason, String.t()}
            ]

  @doc """
    Updates a guild, see `t:modify_guild_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild).
  """
  @spec modify_guild(
          guild :: Util.guild_id_resolvable(),
          data :: modify_guild_data()
        ) :: {:ok, Guild.t()} | {:error, term()}
  def modify_guild(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    data =
      data
      |> Map.new()
      |> Map.update(:icon, nil, fn icon ->
        if icon, do: with({:ok, binary} <- Util.resolve_file(icon), do: binary |> Base.encode64())
      end)
      |> Map.update(:splash, nil, fn splash ->
        if splash,
          do: with({:ok, binary} <- Util.resolve_file(splash), do: binary |> Base.encode64())
      end)

    case data do
      %{icon: {:error, error}} ->
        {:error, error}

      %{splash: {:error, error}} ->
        {:error, error}

      _ ->
        Rest.Base.queue(:post, Endpoints.guild(guild_id), data)
        |> create(Guild)
    end
  end

  @doc """
    Deletes a guild, can only be used if the executing user is the owner.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#delete-guild).
  """
  @spec delete_guild(guild :: Util.guild_id_resolvable()) :: :ok | {:error, term()}
  def delete_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:delete, Endpoints.guild(guild_id))
  end

  @typedoc """
    Used to filter audit log results via `get_audit_logs/2`.
    The `:user_id` field refers to the executor and not the target of the log.
  """
  @type audit_log_options ::
          %{
            optional(:user_id) => snowflake(),
            optional(:action_type) => pos_integer(),
            optional(:before) => snowflake(),
            optional(:limit) => pos_integer()
          }
          | [
              {:user_id, snowflake()}
              | {:action_type, pos_integer()}
              | {:before, snowflake()}
              | {:limit, pos_integer}
            ]

  @doc """
    Gets the audit logs for a guild
  """
  @spec get_audit_logs(guild :: Util.guild_id_resolvable(), options :: audit_log_options() | nil) ::
          {:ok, AuditLog.t()} | {:error, term()}
  def get_audit_logs(guild, options \\ []) do
    guild_id = Util.resolve_guild_id(guild)
    body = Map.new(options)

    Rest.Base.queue(:get, Endpoints.guild_audit_logs(guild_id), "", [], params: body)
    |> create(AuditLog)
  end

  @doc """
    Gets all channels from a guild via the api.
    This should usually, due to caching, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-channels)-
  """
  @spec get_guild_channels(guild :: Util.guild_id_resolvable()) ::
          {:ok, [Channel.t()]} | {:error, term()}
  def get_guild_channels(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild(guild_id, "channels"))
    |> create(Channel)
  end

  @typedoc """
    Used to create a channel via `create_guild_channel/2`.

    Notes:
   * `:name` has to be [2-100] chars and may only contain [a-Z_-]
  """
  @type create_guild_channel_data ::
          %{
            optional(:name) => String.t(),
            optional(:type) => non_neg_integer(),
            optional(:bitrate) => non_neg_integer() | nil,
            optional(:user_limit) => integer() | nil,
            optional(:permission_overwrites) => [
              Overwrite.t()
              | %{
                  required(:id) => snowflake(),
                  required(:type) => String.t(),
                  optional(:allow) => non_neg_integer(),
                  optional(:deny) => non_neg_integer()
                }
            ],
            optional(:parent_id) => snowflake() | nil,
            optional(:nsfw) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:type, pos_integer()}
              | {:bitrate, non_neg_integer() | nil}
              | {:user_limit, integer() | nil}
              | {:permission_overwrites,
                 [
                   Overwrite.t()
                   | %{
                       required(:id) => snowflake(),
                       required(:type) => String.t(),
                       optional(:allow) => non_neg_integer(),
                       optional(:deny) => non_neg_integer()
                     }
                 ]}
              | {:parent_id, snowflake() | nil}
              | {:nsfw, boolean()}
              | {:reason, String.t()}
            ]

  @doc """
    Creates a channel in a guild, see `t:create_guild_channel_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#create-guild-channel).
  """
  @spec create_guild_channel(
          guild :: Util.guild_id_resolvable(),
          data :: create_guild_channel_data()
        ) :: {:ok, Channel.t()} | {:error, term()}
  def create_guild_channel(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:post, Endpoints.guild(guild_id, "channels"), Map.new(data))
    |> create(Channel)
  end

  @type modify_guild_channel_positions_data_entry ::
          {Channel.t(), integer()}
          | {snowflake, integer()}
          | %{required(:channel) => Channel.t(), required(:position) => integer()}
          | %{required(:id) => snowflake(), required(:position) => integer()}

  @doc """
    Modifyies the position of a list of channels in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-channel-positions).
  """
  @spec modify_guild_channel_positions(
          guild :: Util.guild_id_resolvable(),
          channels :: [modify_guild_channel_positions_data_entry()]
        ) :: :ok | {:error, term()}
  def modify_guild_channel_positions(guild, channels) do
    guild_id = Util.resolve_guild_id(guild)
    channel_positions = Enum.map(channels, &Util.resolve_channel_position/1)

    Rest.Base.queue(:patch, Endpoints.guild(guild_id, "channels"), channel_positions)
  end

  @doc """
    Fetches a member from the api.

    This may be necessary for offline members in large guilds.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-member).
  """
  @spec get_guild_member(
          guild :: Util.guild_id_resolvable(),
          user :: Util.user_id_resolvable()
        ) :: {:ok, Member.t()} | {:error, term()}
  def get_guild_member(guild, user) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    Rest.Base.queue(:get, Endpoints.guild_members(guild_id, user_id))
    |> create(Member)
  end

  @type list_guild_members_options ::
          %{
            optional(:limit) => pos_integer(),
            optional(:after) => snowflake()
          }
          | [{:limit, pos_integer()} | {:after, snowflake()}]

  @spec list_guild_members(
          guild :: Util.guild_id_resolvable(),
          options :: list_guild_members_options()
        ) :: {:ok, [Member.t()]} | {:error, term()}

  @doc """
    Gets a list of members from the guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#list-guild-members).
  """
  def list_guild_members(guild, options \\ []) do
    guild_id = Util.resolve_guild_id(guild)

    data = Map.new(options)

    Rest.Base.queue(:get, Endpoints.guild_members(guild_id), data)
    |> create(Member)
  end

  @typedoc """
    Used to add a member to a guild via `add_guild_member/3`.
  """
  @type add_guild_member_data ::
          %{
            required(:access_token) => String.t(),
            optional(:nick) => String.t() | nil,
            optional(:roles) => [snowflake()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:access_token, String.t()}
              | {:nick, String.t() | nil}
              | {:roles, [snowflake()]}
              | {:mute, boolean()}
              | {:deaf, boolean()}
              | {:reason, String.t()}
            ]

  @doc """
    Adds a user to a guild via a provided oauth2 access token with the `guilds.join` scope.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#add-guild-member).
  """
  @spec add_guild_member(
          guild :: Util.guild_id_resolvable(),
          user :: Util.user_id_resolvable(),
          data :: add_guild_member_data()
        ) :: {:ok, Member.t()} | {:error, term()}
  def add_guild_member(guild, user, data) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    data = Map.new(data)

    Rest.Base.queue(:put, Endpoints.guild_members(guild_id, user_id), data)
    |> create(Member)
  end

  @typedoc """
    Used to modify a member with `modify_guild_member/3`.

    Notes:
      * `:mute`, `:deaf`, and `:channel_id` will silently be discarded by discord if the member is not connected to a voice channel.
  """
  @type modify_guild_member_data ::
          %{
            optional(:nick) => String.t() | nil,
            optional(:roles) => [snowflake()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:channel_id) => snowflake(),
            optional(:reason) => String.t()
          }
          | [
              {:nick, String.t() | nil}
              | {:roles, [snowflake()]}
              | {:mute, boolean()}
              | {:deaf, boolean()}
              | {:channel_id, snowflake()}
              | {:reason, String.t()}
            ]

  @doc """
    Modifies a member in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-member).
  """
  @spec modify_guild_member(
          guild :: Util.guild_id_resolvable(),
          member :: Util.user_id_resolvable(),
          data :: modify_guild_member_data()
        ) :: :ok | {:error, term()}
  def modify_guild_member(guild, member, data) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)

    data = Map.new(data)

    Rest.Base.queue(:patch, Endpoints.guild_members(guild_id, user_id), data)
  end

  @doc """
    Modifies the nickname of the current user in a guild.

    Yes, you read correctly, that has its own endpoint.
    Great, isn't it?

    For more informations, but not an answer to the question why, see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-current-user-nick).
  """
  @spec modify_current_users_nick(
          guild :: Util.guild_id_resolvable(),
          nick :: String.t(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def modify_current_users_nick(guild, nick, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:patch, Endpoints.guild_own_nick(guild_id), %{nick: nick, reason: reason})
  end

  @doc """
    Adds a role to a member.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#add-guild-member-role).
  """
  @spec add_guild_member_role(
          guild :: Util.guild_id_resolvable(),
          member :: Util.user_id_resolvable(),
          role :: Util.role_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}

  def add_guild_member_role(guild, member, role, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)
    role_id = Util.resolve_role_id(role)

    Rest.Base.queue(:put, Endpoints.guild_member_roles(guild_id, user_id, role_id), %{
      reason: reason
    })
  end

  @doc """
    Removes a role from a member.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#remove-guild-member-role).
  """
  @spec remove_guild_member_role(
          guild :: Util.guild_id_resolvable(),
          member :: Util.user_id_resolvable(),
          role :: Util.role_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}

  def remove_guild_member_role(guild, member, role, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)
    role_id = Util.resolve_role_id(role)

    Rest.Base.queue(:delete, Endpoints.guild_member_roles(guild_id, user_id, role_id), %{
      reason: reason
    })
  end

  @doc """
    Fetches a map of banned users along their ban reasons.

    For more informations see [discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-bans).
  """
  @spec get_guild_bans(guild :: Util.guild_id_resolvable()) ::
          {:ok, %{snowflake() => %{user: User.t(), reason: String.t() | nil}}} | {:error, term()}
  def get_guild_bans(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_bans(guild_id))
    |> Map.new(fn entry ->
      Map.update!(entry, :user, &Structs.create(&1, User))
      {entry.user.id, entry}
    end)
  end

  @doc """
    Fetches a single ban entry by id.

  > Returns {:error, %Crux.Rest.ApiError{status_code: 404, code: 10026, ...}} when the user is not banned.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-ban).
  """
  @spec get_guild_ban(guild :: Util.guild_id_resolvable(), user :: Util.user_id_resolvable()) ::
          {:ok, %{user: User.t(), reason: String.t() | nil}} | {:error, term()}
  def get_guild_ban(guild, user) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    case Rest.Base.queue(:get, Endpoints.guild_bans(guild_id, user_id)) do
      {:ok, entry} ->
        {:ok, Map.update!(entry, :user, &Structs.create(&1, User))}

      other ->
        other
    end
  end

  @doc """
    Bans a user  from a guild, the user does not have to be part of the guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#create-guild-ban).
  """
  @spec create_guild_ban(
          guild :: Util.guild_id_resolvable(),
          user :: Util.user_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def create_guild_ban(guild, user, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    Rest.Base.queue(:put, Endpoints.guild_bans(guild_id, user_id), %{reason: reason})
  end

  @doc """
    Removes a ban for a user from a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#remove-guild-ban).
  """
  @spec remove_guild_ban(
          guild :: Util.guild_id_resolvable(),
          user :: Util.user_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def remove_guild_ban(guild, user, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    Rest.Base.queue(:delete, Endpoints.guild_bans(guild_id, user_id), %{reason: reason})
  end

  @doc """
    Fetches a list of roles in a guild.
    This should usually, due to caching, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-roles).
  """
  @spec get_guild_roles(guild :: Util.guild_id_resolvable()) ::
          {:ok, %{snowflake() => Role.t()}} | {:error, term()}
  def get_guild_roles(guild) do
    guild_id = Util.resolve_guild_id(guild)

    with {:ok, data} <- Rest.Base.queue(:get, Endpoints.guild_roles(guild_id)) do
      {:ok, Structs.Util.raw_data_to_map(data, Role)}
    end
  end

  @typedoc """
    Used to create a role in a guild with `create_guild_role/2`.
  """
  @type guild_role_data ::
          %{
            optional(:name) => String.t(),
            optional(:permissions) => non_neg_integer(),
            optional(:color) => non_neg_integer(),
            optional(:hoist) => boolean(),
            optional(:mentionable) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:permissions, non_neg_integer()}
              | {:color, non_neg_integer()}
              | {:hoist, boolean()}
              | {:mentionable, boolean()}
              | {:reason, String.t()}
            ]

  @doc """
    Creates a role in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#create-guild-role).
  """
  @spec create_role(guild :: Util.guild_id_resolvable(), data :: guild_role_data()) ::
          {:ok, Role.t()} | {:error, term()}
  def create_role(guild, %{} = data) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_roles(guild_id), Map.new(data))
    |> create(Role)
  end

  @doc """
    Modifies the positions of a list of role objects for a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-role-positions).
  """
  @spec modify_guild_role_positions(
          guild :: Util.guild_id_resolvable(),
          data :: Util.modify_guild_role_positions_data()
        ) :: {:ok, %{snowflake() => Role.t()}} | {:error, term()}
  def modify_guild_role_positions(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    data = Enum.map(data, &Util.resolve_guild_role_position/1)

    Rest.Base.queue(:patch, Endpoints.guild_roles(guild_id), data)
  end

  @doc """
    Modifies a role in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
  """
  @spec modify_guild_role(
          guild :: Util.guild_id_resolvable(),
          role :: Util.role_id_resolvable(),
          data :: guild_role_data()
        ) :: {:ok, Role.t()} | {:error, term()}
  def modify_guild_role(guild, role, data) do
    guild_id = Util.resolve_guild_id(guild)
    role_id = Util.resolve_guild_id(role)

    Rest.Base.queue(:patch, Endpoints.guild_roles(guild_id, role_id), Map.new(data))
  end

  @doc """
    Deletes a role in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#delete-guild-role).
  """
  @spec delete_guild_role(
          guild :: Util.guild_id_resolvable(),
          role :: Util.role_id_resolvable(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def delete_guild_role(guild, role, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    role_id = Util.resolve_role_id(role)

    Rest.Base.queue(:delete, Endpoints.guild_roles(guild_id, role_id), %{reason: reason})
  end

  @doc """
    Fetches the number of members in a guild that would be removed when pruned.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count).
  """
  @spec get_guild_prune_count(guild :: Util.guild_id_resolvable(), days :: pos_integer()) ::
          {:ok, non_neg_integer()} | {:error, term()}
  def get_guild_prune_count(guild, days) do
    guild_id = Util.resolve_guild_id(guild)

    case Rest.Base.queue(:get, Endpoints.guild(guild_id, "prune"), "", [], params: [days: days]) do
      {:ok, %{pruned: not_actually_pruned}} ->
        {:ok, not_actually_pruned}
    end
  end

  @doc """
    Prunes members in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#begin-guild-prune).
  """
  @spec begin_guild_prune(guild :: Util.guild_id_resolvable(), days :: pos_integer()) ::
          {:ok, non_neg_integer()} | {:error, term()}
  def begin_guild_prune(guild, days) do
    guild_id = Util.resolve_guild_id(guild)

    case Rest.Base.queue(:post, Endpoints.guild(guild_id, "prune"), "", [], params: [days: days]) do
      {:ok, %{pruned: pruned}} ->
        {:ok, pruned}
    end
  end

  @doc """
    Fetches a list of voice regions for a guild. Returns VIP servers when the guild is VIP-enabled.

  > Returns a list of [Voice Region Objects](https://discordapp.com/developers/docs/resources/voice#voice-region-object).

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-voice-regions).
  """
  @spec get_guild_voice_regions(guild :: Util.guild_id_resolvable()) ::
          {:ok, term()} | {:error, term()}
  def get_guild_voice_regions(guild) do
    guild_id = Util.resolve_guild_id(guild)

    case Rest.Base.queue(:post, Endpoints.guild(guild_id, "regions")) do
      {:ok, thing} ->
        {:ok, thing}
    end
  end

  @doc """
    Fetches all available invites in a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-invites).
  """
  @spec get_guild_invites(guild :: Util.guild_id_resolvable()) ::
          {:ok, %{String.t() => Invite.t()}} | {:error, term()}
  def get_guild_invites(guild) do
    guild_id = Util.resolve_guild_id(guild)

    case Rest.Base.queue(:get, Endpoints.guild(guild_id, "invites")) do
      {:ok, data} ->
        Structs.Util.raw_data_to_map(data, Invite, :code)
    end
  end

  @doc """
    Fetches a list of guild integrations.

  > Returns a list of [Integration Objects](https://discordapp.com/developers/docs/resources/guild#integration-object).

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-integration).
  """
  @spec get_guild_integrations(guild :: Util.guild_id_resolvable()) ::
          {:ok, list()} | {:error, term()}
  def get_guild_integrations(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_integrations(guild_id))
  end

  @doc """
    Attaches an integration from the current user to a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#create-guild-integration).
  """
  @spec create_guild_integration(
          guild :: Util.guild_id_resolvable(),
          data ::
            %{type: String.t(), id: snowflake()}
            | [{:type, String.t()} | {:id, snowflake()}]
        ) :: :ok | {:error, term()}
  def create_guild_integration(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_integrations(guild_id), Map.new(data))
  end

  @doc """
    Modifies an integreation for a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-integration).
  """
  @spec modify_guild_integration(
          guild :: Util.guild_id_resolvable(),
          integration_id :: snowflake(),
          data ::
            %{
              optional(:expire_behavior) => integer(),
              optional(:expire_grace_period) => integer(),
              optional(:enable_emoticons) => boolean()
            }
            | [
                {:expire_behavior, integer()}
                | {:expire_grace_period, integer()}
                | {:enable_emoticons, boolean()}
              ]
        ) :: :ok | {:error, term()}
  def modify_guild_integration(guild, integration_id, data) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_integrations(guild_id, integration_id), Map.new(data))
  end

  @doc """
    Deletes an integration from a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#delete-guild-integration).
  """
  @spec delete_guild_integration(
          guild :: Util.guild_id_resolvable(),
          integration_id :: snowflake()
        ) :: :ok | {:error, term()}
  def delete_guild_integration(guild, integration_id) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:delete, Endpoints.guild_integrations(guild_id, integration_id))
  end

  @doc """
    Syncs an integration for a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#sync-guild-integration).
  """
  @spec sync_guild_integration(guild :: Util.guild_id_resolvable(), integration_id :: snowflake()) ::
          :ok | {:error, term()}
  def sync_guild_integration(guild, integration_id) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:post, Endpoints.guild_integrations(guild_id, integration_id))
  end

  @doc """
    Fetches a guild's embed (server widget).

  > Returns a [Guild Embed Object](https://discordapp.com/developers/docs/resources/guild#get-guild-embed).

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-embed).
  """
  @spec get_guild_embed(guild :: Util.guild_id_resolvable()) :: {:ok, term()} | {:error, term()}
  def get_guild_embed(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild(guild_id, "embed"))
  end

  @doc """
    Modifies a guild's embed (server widget).

  > Returns the updated [Guild Embed Object](https://discordapp.com/developers/docs/resources/guild#get-guild-embed).

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-guild-embed).
  """
  @spec modify_guild_embed(
          guild :: Util.guild_id_resolvable(),
          data ::
            %{
              optional(:enabled) => boolean(),
              optional(:channel_id) => snowflake()
            }
            | [{:enabled, boolean()} | {:channel_id, snowflake()}]
        ) :: {:ok, term()} | {:error, term()}
  def modify_guild_embed(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:patch, Endpoints.guild(guild_id, "embed"), Map.new(data))
  end

  @doc """
    Fetches the vanity url of a guild, if any
  """
  @spec get_guild_vanity_url(guild :: Util.guild_id_resolvable()) ::
          {:ok, String.t()} | {:error, term()}
  def get_guild_vanity_url(guild) do
    guild_id = Util.resolve_guild_id(guild)

    case Rest.Base.queue(:get, Endpoints.guild(guild_id, "vanity-url")) do
      {:ok, %{code: code}} ->
        {:ok, code}
    end
  end

  ### End Guild

  ### Start Webhook

  @doc """
    Fetches a guild's webhook list

  > Returns a list of [Webhook Objects](https://discordapp.com/developers/docs/resources/webhook#webhook-object)

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#get-guild-webhooks)
  """
  @spec list_guild_webhooks(guild :: Util.guild_id_resolvable()) ::
          {:ok, [Webhook.t()]} | {:error, term()}
  def list_guild_webhooks(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:get, Endpoints.guild_webhooks(guild_id))
    |> create(Webhook)
  end

  @doc """
    Fetches a channel's webhook list

  > Returns a list of [Webhook Objects](https://discordapp.com/developers/docs/resources/webhook#webhook-object)

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#get-channel-webhooks)
  """
  @spec list_channel_webhooks(channel :: Util.channel_id_resolvable()) ::
          {:ok, [Webhook.t()]} | {:error, term()}
  def list_channel_webhooks(channel) do
    channel_id = Util.resolve_channel_id(channel)

    Rest.Base.queue(:get, Endpoints.channel_webhooks(channel_id))
    |> create(Webhook)
  end

  @doc """
    Fetches a webhook

  > Returns a [Webhook Object](https://discordapp.com/developers/docs/resources/webhook#webhook-object)

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#get-webhook)
  """
  @spec get_webhook(user :: Util.user_id_resolvable(), token :: String.t() | nil) ::
          {:ok, [Webhook.t()]} | {:error, term()}
  def get_webhook(user, token \\ nil) do
    user_id = Util.resolve_user_id(user)

    Rest.Base.queue(:get, Endpoints.webhook(user_id, token))
    |> create(Webhook)
  end

  @doc """
    Updates a webhook

  > Returns the updated [Webhook Object](https://discordapp.com/developers/docs/resources/webhook#webhook-object)

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#modify-webhook)
  """
  @spec update_webhook(
          user :: Util.user_id_resolvable(),
          token :: String.t() | nil,
          data ::
            %{
              optional(:name) => String.t(),
              optional(:avatar) => String.t(),
              optional(:channel_id) => snowflake()
            }
            | [{:name, String.t()} | {:avatar, String.t()} | {:channel_id, snowflake()}]
        ) :: {:ok, Webhook.t()} | {:error, term()}
  def update_webhook(user, token \\ nil, data) do
    user_id = Util.resolve_user_id(user)
    body = Map.new(data)

    Rest.Base.queue(:patch, Endpoints.webhook(user_id, token), body)
    |> create(Webhook)
  end

  @doc """
    Deletes a webhook

  > Returns :ok on success, otherwise an error tuple

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#delete-webhook)
  """
  @spec delete_webhook(user :: Util.user_id_resolvable(), token :: String.t() | nil) ::
          :ok | {:error, term()}
  def delete_webhook(user, token \\ nil) do
    user_id = Util.resolve_user_id(user)
    Rest.Base.queue(:delete, Endpoints.webhook(user_id, token))
  end

  @typedoc """
    Used for sending discord webhooks. For more information on non-discord webhooks, check
    [Slack Docs](https://api.slack.com/custom-integrations/outgoing-webhooks) or
    [Github Docs](https://developer.github.com/webhooks/)
  """
  @type execute_webhook_options :: %{
          optional(:content) => String.t(),
          optional(:username) => String.t(),
          optional(:avatar_url) => String.t(),
          optional(:tts) => boolean(),
          optional(:file) => file_list_entry(),
          optional(:embeds) => [embed()]
        }
  @doc """
    Executes a webhook

  > Returns :ok by default. If wait parameter is set to true, returns a tuple returning the message object or error

    For more information see [Discord Docs](https://discordapp.com/developers/docs/resources/webhook#execute-webhook)
  """
  @spec execute_webhook(
          webhook :: Webhook.t(),
          wait :: boolean | nil,
          data :: execute_webhook_options()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  @spec execute_webhook(
          user :: Util.user_id_resolvable(),
          token :: String.t(),
          wait :: boolean | nil,
          data :: execute_webhook_options()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  def execute_webhook(webhook = %Webhook{}, data) do
    execute_webhook(webhook.id, webhook.token, false, data)
  end

  def execute_webhook(user, token, wait \\ false, data)

  def execute_webhook(webhook = %Webhook{}, wait, _, data) do
    execute_webhook(webhook.id, webhook.token, wait, data)
  end

  def execute_webhook(user, token, wait, data) do
    user_id = Util.resolve_user_id(user)
    body = Map.new(data)
    Rest.Base.queue(:post, Endpoints.webhook(user_id, token), body, [], params: [wait: wait])
  end

  @doc """
    Executes a slack webhook

  > Returns :ok by default. If wait parameter is set to true, returns a tuple returning the message object or error

    For more information see [Slack Docs](https://api.slack.com/custom-integrations/outgoing-webhooks)
  """
  @spec execute_slack_webhook(
          webhook :: Webhook.t(),
          wait :: boolean | nil,
          data :: term()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  @spec execute_slack_webhook(
          user :: Util.user_id_resolvable(),
          token :: String.t(),
          wait :: boolean | nil,
          data :: term()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  def execute_slack_webhook(webhook = %Webhook{}, data) do
    execute_slack_webhook(webhook.id, webhook.token, false, data)
  end

  def execute_slack_webhook(user, token, wait \\ false, data)

  def execute_slack_webhook(webhook = %Webhook{}, wait, _, data) do
    execute_slack_webhook(webhook.id, webhook.token, wait, data)
  end

  def execute_slack_webhook(user, token, wait, data) do
    user_id = Util.resolve_user_id(user)
    body = Map.new(data)

    Rest.Base.queue(
      :post,
      Endpoints.webhook_slack(user_id, token),
      body,
      [],
      params: [wait: wait]
    )
  end

  @doc """
    Executes a github webhook

  > Returns :ok by default. If wait parameter is set to true, returns a tuple returning the message object or error

    For more information see [Github Docs](https://developer.github.com/webhooks/)
  """
  @spec execute_github_webhook(
          webhook :: Webhook.t(),
          wait :: boolean | nil,
          data :: term()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  @spec execute_github_webhook(
          user :: Util.user_id_resolvable(),
          token :: String.t(),
          wait :: boolean | nil,
          data :: term()
        ) :: :ok | {:ok, Message.t()} | {:error, term}
  def execute_github_webhook(webhook = %Webhook{}, data) do
    execute_github_webhook(webhook.id, webhook.token, false, data)
  end

  def execute_github_webhook(user, token, wait \\ false, data)

  def execute_github_webhook(webhook = %Webhook{}, wait, _, data) do
    execute_github_webhook(webhook.id, webhook.token, wait, data)
  end

  def execute_github_webhook(user, token, wait, data) do
    user_id = Util.resolve_user_id(user)
    body = Map.new(data)

    Rest.Base.queue(
      :post,
      Endpoints.webhook_github(user_id, token),
      body,
      [],
      params: [wait: wait]
    )
  end

  ### End Webhook

  @doc """
    Fetches an invite from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/invite#get-invite).
  """
  @spec get_invite(code :: String.t()) :: {:ok, Invite.t()} | {:error, term()}
  def get_invite(code) do
    Rest.Base.queue(:get, Endpoints.invite(code), "", [], params: %{with_counts: true})
    |> create(Invite)
  end

  @doc """
    Deletes an invite.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/invite#get-invite).
  """
  @spec delete_invite(invite_or_code :: String.t() | Invite.t()) ::
          {:ok, Invite.t()} | {:error, term()}
  def delete_invite(%Invite{code: code}), do: delete_invite(code)

  def delete_invite(code) do
    Rest.Base.queue(:delete, Endpoints.invite(code))
    |> create(Invite)
  end

  @doc """
    Fetches a user from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#get-user).
  """
  @spec get_user(user :: Util.user_id_resolvable() | String.t()) ::
          {:ok, User.t()} | {:error, term()}
  def get_user(user) do
    Rest.Base.queue(:get, Endpoints.users(user))
    |> create(User)
  end

  @typedoc """
    Used to modify the currently logged in `modify_current_user/1`.

    - `:avatar` is similarly to `u:file_list_entry/0` except you obviously can't "rename" the avatar.
  """
  @type modify_current_user_data ::
          %{
            optional(:username) => String.t(),
            optional(:avatar) => String.t() | binary() | nil
          }
          | [{:username, String.t()} | {:avatar, String.t() | binary() | nil}]

  @doc """
    Modifes the currently logged in user.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#modify-current-user).
  """
  @spec modify_current_user(data :: modify_current_user_data()) ::
          {:ok, User.t()} | {:error, term()}
  def modify_current_user(data) do
    data = Map.new(data)

    Rest.Base.queue(:post, Endpoints.me(), data)
    |> create(User)
  end

  @typedoc """
    Used to list the current user's guilds in `get_current_user_guild_/1`.
  """
  @type get_current_user_guild_data :: %{
          optional(:before) => snowflake(),
          optional(:after) => snowflake(),
          optional(:limit) => pos_integer()
        }

  @doc """
    Fetches a list of partial `Crux.Structs.Guilds` the current user is a member of.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#get-current-user-guilds).
  """
  @spec get_current_user_guilds(data :: get_current_user_guild_data()) ::
          {:ok, [Guild.t()]} | {:error, term()}
  def get_current_user_guilds(data) do
    Rest.Base.queue(:get, Endpoints.me_guilds(), Map.new(data))
    |> create(Guild)
  end

  @doc """
    Leaves a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#leave-guild).
  """
  @spec leave_guild(guild :: Util.guild_id_resolvable()) :: :ok | {:error, term()}
  def leave_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    Rest.Base.queue(:delete, Endpoints.me_guilds(guild_id))
  end

  @doc """
    Fetches a list of `Crux.Structs.Channel`. (DMChannels in this case)

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#get-user-dms).
  """
  @spec get_user_dms() :: {:ok, [Channel.t()]} | {:error, term()}
  def get_user_dms() do
    Rest.Base.queue(:get, Endpoints.me())
    |> create(Channel)
  end

  @doc """
    Creates a new dm channel with a user.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#create-dm).
  """
  @spec create_dm(user :: Util.user_id_resolvable()) :: {:ok, Channel.t()} | {:error, term()}
  def create_dm(user) do
    user_id = Util.resolve_user_id(user)

    Rest.Base.queue(:post, Endpoints.me("channels"), %{recipient_id: user_id})
    |> create(Channel)
  end

  @typedoc """
    Used to create a group dm with `create_group_dm/1 `.

    - `:access_tokens` are meant to be obtained on your own via oauth2, they have to have the `gdm.join` scope.
    - `:nicks` is a map of ids and their respective nicknames to give a user.
  """
  @type create_group_dm_data ::
          %{
            required(:access_tokens) => [String.t()],
            optional(:nicks) => %{required(Util.user_id_resolvable()) => String.t()}
          }
          | [{:access_tokens, String.t()} | {:nicks, %{}}]

  @doc """
    Creates a group dm with multiple users.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/user#create-group-dm).
  """
  @spec create_group_dm(data :: create_group_dm_data()) :: {:ok, Channel.t()} | {:error, term()}
  def create_group_dm(data) do
    data =
      data
      |> Map.new()
      |> Map.update(:nicks, %{}, &Enum.map(&1, fn user -> Util.resolve_user_id(user) end))

    Rest.Base.queue(:post, Endpoints.me(), data)
    |> create(Channel)
  end

  @doc """
    Fetches the gateway url from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/topics/gateway#get-gateway).
  """
  @spec gateway() :: {:ok, term()} | {:error, term()}
  def gateway() do
    Rest.Base.queue(:get, Endpoints.gateway())
  end

  @doc """
     Fetches the gateway url along a recommended shards count from the api.

     For more informations see [Discord Docs](https://discordapp.com/developers/docs/topics/gateway#get-gateway-bot).
  """
  @spec gateway_bot() :: {:ok, term()} | {:error, term()}
  def gateway_bot() do
    Rest.Base.queue(:get, Endpoints.gateway_bot())
  end
end
