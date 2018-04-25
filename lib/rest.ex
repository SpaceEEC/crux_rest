defmodule Crux.Rest do
  @moduledoc """
    Collection of Rest functions.
  """
  alias Crux.Structs
  alias Crux.Structs.{Channel, Emoji, Guild, Invite, Member, Message, User}
  alias Crux.Rest
  alias Crux.Rest.{Endpoints, Util}

  defp create(:ok, _to), do: :ok
  defp create({:ok, res}, to), do: {:ok, Structs.create(res, to)}
  defp create({:error, _} = res, _to), do: res

  ### Message
  @typedoc """
    A Discord snowflake, fits in a 64bit integer.

    Received as integers via the gateway, but as strings via http.
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
          channel_or_message :: Message.t() | Channel.t() | snowflake(),
          args :: create_message_data()
        ) :: {:ok, Message.t()} | {:error, term()}
  def create_message(channel_or_message, args)
  def create_message(%Message{channel_id: channel_id}, args), do: create_message(channel_id, args)
  def create_message(%Channel{id: channel_id}, args), do: create_message(channel_id, args)

  def create_message(channel_id, not_map) when not is_map(not_map),
    do: create_message(channel_id, Map.new(not_map))

  def create_message(channel_id, %{files: files} = args) when is_number(channel_id) do
    Enum.reduce_while(files, [], fn file ->
      with {:error, error} <- Util.map_file(file) do
        {:halt, error}
      else
        tuple ->
          {:cont, tuple}
      end
    end)
    |> case do
      form_data when is_list(form_data) ->
        args = Map.delete(args, :files)

        form_data =
          if Map.has_key?(args, :embed) || Map.has_key?(args, :content),
            do: [{"payload_json", Poison.encode!(args)} | form_data],
            else: form_data

        create_message(channel_id, {:multipart, form_data}, [
          {"content-type", "multipart/form-data"}
        ])

      {:error, _error} = error ->
        error
    end
  end

  @doc false
  def create_message(channel_id, args, disposition \\ []) do
    Rest.Base.queue(:post, Endpoints.channel_messages(channel_id), args, disposition)
    |> create(Message)
  end

  @typedoc """
    Used to edit messages via `edit_message/2` or `edit_message/3`.

    The content my not exceed 2000 chars, this limit is enfored on discord's end.
  """
  @type message_edit_data ::
          %{
            optional(:content) => String.t(),
            optional(:embed) => embed()
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
          channel_id :: Channel.t() | snowflake(),
          message_id :: snowflake(),
          args :: message_edit_data()
        ) :: {:ok, Message.t()} | {:error, term()}
  def edit_message(%Channel{id: channel_id}, message_id, args),
    do: edit_message(channel_id, message_id, args)

  def edit_message(channel_id, message_id, args) do
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
          channel :: Channel.t() | snowflake(),
          message_id :: snowflake()
        ) :: {:ok, Message} | {:error, term()}
  def delete_message(channel, message_id)

  def delete_message(%Channel{id: channel_id}, message_id),
    do: delete_message(channel_id, message_id)

  def delete_message(channel_id, message_id) do
    Rest.Base.queue(:delete, Endpoints.channel_messages(channel_id, message_id))
  end

  @doc """
    Deletes 2-100 messages not older than 14 days.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages)
  """
  @spec delete_messages(
          channel :: Channel.t() | snowflake(),
          messages :: [Message.t() | snowflake()]
        ) :: :ok | {:error, term()}
  def delete_messages(channel, messages)

  def delete_messages(%Channel{id: channel_id}, messages),
    do: delete_messages(channel_id, messages)

  def delete_messages(channel_id, messages) do
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
          channel :: Channel.t() | snowflake(),
          message_id :: snowflake()
        ) :: {:ok, Message} | {:error, term()}
  def get_message(channel, message_id)

  def get_message(%Channel{id: channel_id}, message_id), do: get_message(channel_id, message_id)

  def get_message(channel_id, message_id) when is_number(channel_id and is_number(message_id)) do
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
          channel :: Channel.t() | snowflake(),
          args :: get_messages_data()
        ) :: {:ok, [Message.t()]} | {:error, term()}

  def get_messages(channel, args \\ [])
  def get_messages(%Channel{id: channel_id}, args), do: get_messages(channel_id, args)

  def get_messages(channel_id, args) do
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
          message :: Message.t(),
          emoji :: Reaction.t() | Emoji.t() | String.t()
        ) :: :ok | {:error, term()}

  def create_reaction(message, emoji)

  def create_reaction(%Message{channel_id: channel_id, id: message_id}, emoji),
    do: create_reaction(channel_id, message_id, emoji)

  @doc """
  Creates a reaction on a message, or increases its count by one.

  For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#create-reaction).
  """
  @spec create_reaction(
          channel :: Channel.t() | snowflake(),
          message_id :: snowflake(),
          emoji :: Reaction.t() | Emoji.t() | String.t()
        ) :: :ok | {:error, term()}
  def create_reaction(channel, message_id, emoji)

  def create_reaction(%Channel{id: channel_id}, message_id, emoji),
    do: create_reaction(channel_id, message_id, emoji)

  def create_reaction(channel_id, message_id, emoji) do
    emoji =
      emoji
      |> Util.resolve_emoji_identifier()
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
          channel :: Channel.t() | snowflake(),
          message :: Message.t() | snowflake(),
          emoji :: Reaction.t() | Emoji.t() | String.t(),
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
          emoji :: Reaction.t() | Emoji.t() | String.t(),
          args :: get_reactions_data()
        ) :: {:ok, [User.t()]} | {:error, term()}
  def get_reactions(%Message{channel_id: channel_id, id: message_id}, emoji, args, _),
    do: get_reactions(channel_id, message_id, emoji, args)

  def get_reactions(%Channel{id: channel_id}, message_id, emoji, args),
    do: get_reactions(channel_id, message_id, emoji, args)

  def get_reactions(channel_id, %Message{id: message_id}, emoji, args),
    do: get_reactions(channel_id, message_id, emoji, args)

  def get_Reactions(channel_id, message_id, emoji, args) do
    emoji =
      emoji
      |> Util.resolve_emoji_identifier()
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
          channel :: Channel.t() | snowflake(),
          message :: snowflake(),
          emoji :: Reaction.t() | Emoji.t() | String.t(),
          user :: Member.t() | User.t() | snowflake()
        ) :: :ok | {:error, term()}
  def delete_reaction(
        message_or_channel,
        emoji_or_message_id,
        emoji_or_maybe_user \\ "@me",
        mayber_user \\ "@me"
      )

  def delete_reaction(%Message{channel_id: channel_id, id: message_id}, emoji, user, _),
    do: delete_reaction(channel_id, message_id, emoji, user)

  def delete_reaction(%Channel{id: channel_id}, message_id, emoji, user),
    do: delete_reaction(channel_id, message_id, emoji, user)

  def delete_reaction(channel_id, message_id, emoji, user) do
    emoji =
      emoji
      |> Util.resolve_emoji_identifier()
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
          emoji :: Reaction.t() | Emoji.t() | String.t()
        ) :: :ok | {:error, term()}
  def delete_all_reactions(message, emoji)

  def delete_all_reactions(%Message{channel_id: channel_id, id: message_id}, emoji),
    do: delete_reaction(channel_id, message_id, emoji)

  @doc """
  Deletes all reactions from a messaage.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-all-reactions).
  """
  @spec delete_all_reactions(
          channel :: Channel.t() | snowflake(),
          message_id :: Message.t() | snowflake(),
          emoji :: Reaction.t() | Emoji.t() | String.t()
        ) :: :ok | {:error, term()}
  def delete_all_reactions(channel, message_id, emoji)

  def delete_all_reactions(%Channel{id: channel_id}, message_id, emoji),
    do: delete_reaction(channel_id, message_id, emoji)

  def delete_all_reactions(channel_id, %Message{id: message_id}, emoji),
    do: delete_reaction(channel_id, message_id, emoji)

  def delete_all_reactions(channel_id, message_id, emoji) do
    emoji =
      emoji
      |> Util.resolve_emoji_identifier()
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
  @spec trigger_typing(message_or_channel :: Message.t() | Channel.t() | snowflake()) ::
          :ok | {:error, term()}
  def trigger_typing(message_or_channel)
  def trigger_typing(%Message{channel_id: channel_id}), do: trigger_typing(channel_id)
  def trigger_typing(%Channel{id: channel_id}), do: trigger_typing(channel_id)

  def trigger_typing(channel_id) do
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
          channel :: Channel | snowflake(),
          message :: snowflake()
        ) :: :ok | {:error, term()}
  def add_pinned_message(channel, message_id)

  def add_pinned_message(%Channel{id: channel_id}, message_id),
    do: add_pinned_message(channel_id, message_id)

  def add_pinned_message(channel_id, message_id),
    do: Rest.Base.queue(:put, Endpoints.channel_pins(channel_id, message_id))

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
          channel :: Channel.t() | snowflake(),
          message :: snowflake()
        ) :: :ok | {:error, term()}
  def delete_pinned_message(%Channel{id: channel_id}, message_id),
    do: delete_pinned_message(channel_id, message_id)

  def delete_pinned_message(channel_id, message_id),
    do: Rest.Base.queue(:delete, Endpoints.channel_pins(channel_id, message_id))

  @doc """
    Gets a channel from the api.
    This should _NOT_ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel)
  """
  @spec get_channel(channel :: Channel.t() | snowflake()) :: {:ok, Channel.t()} | {:error, term()}
  def get_channel(%Channel{id: channel_id}), do: get_channel(channel_id)

  def get_channel(channel_id) do
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

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#modify-channel-json-params).
  """
  @type modify_channel_data ::
          %{
            optional(:name) => String.t() | nil,
            optional(:position) => non_neg_integer(),
            optional(:topic) => String.t() | nil,
            optional(:nsfw) => boolean(),
            optional(:bitrate) => non_neg_integer(),
            optional(:user_limit) => non_neg_integer() | nil,
            optional(:permission_overwrites) => [Overwrite.t()],
            optional(:parent_id) => snowflake(),
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t() | nil}
              | {:position, non_neg_integer()}
              | {:topic, String.t() | nil}
              | {:nsfw, boolean()}
              | {:bitrate, non_neg_integer()}
              | {:user_limit, integer() | nil}
              | {:overwrites, [Overwrite.t()]}
              | {:parent_id, snowflake()}
              | {:reason, String.t()}
            ]

  @doc """
    Modifies a channel, see `t:modify_channel_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#modify-channel).
  """
  @spec modify_channel(
          channel :: Channel.t(),
          args :: modify_channel_data()
        ) :: {:ok, Channel.t()} | {:error, term()}
  def modify_channel(channel, args)
  def modify_channel(%Channel{id: channel_id}, args), do: modify_channel(channel_id, args)

  def modify_channel(channel_id, args) do
    Rest.Base.queue(:patch, Endpoints.channel(channel_id), Map.new(args))
    |> create(Channel)
  end

  @doc """
    Deletes a channel.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#deleteclose-channel).
  """
  @spec delete_channel(
          channel :: Channel.t() | snowflake(),
          reason :: String.t()
        ) :: {:ok, Channel} | {:error, term()}

  def delete_channel(channel, reason \\ nil)
  def delete_channel(%Channel{id: channel_id}, reason), do: delete_channel(channel_id, reason)

  def delete_channel(channel_id, reason) do
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
            optional(:type) => :member | :role | String.t(),
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
          channel :: Channel.t() | snowflake(),
          target :: Overwrite.t() | Member.t() | User.t() | Role.t() | snowflake(),
          data :: edit_channel_permissions_data()
        ) :: :ok | {:error, :missing_target} | {:error, term()}
  def edit_channel_permissions(channel, target, data)

  def edit_channel_permissions(%Channel{id: channel_id}, target, data),
    do: edit_channel_permissions(channel_id, target, data)

  def edit_channel_permissions(channel_id, target, data) when is_map(target) do
    with {type, target_id} <- Util.resolve_overwrite_target(target),
         true <- type != :unknown || data[:type] do
      data =
        data
        |> Map.new()
        |> Map.put_new(:type, type)

      edit_channel_permissions(channel_id, target_id, data)
    else
      _ -> {:error, :invalid_target}
    end
  end

  def edit_channel_permissions(channel_id, target_id, vals) do
    Rest.Base.queue(:put, Endpoints.channel_permissions(channel_id, target_id), Map.new(vals))
  end

  @doc """
    Gets invites for the specified channel from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-channel-invites)
  """
  @spec get_channel_invites(channel :: Channel.t() | snowflake()) ::
          {:ok, [Invite.t()]} | {:error, term()}
  def get_channel_invites(channel)
  def get_channel_invites(%Channel{id: channel_id}), do: get_channel_invites(channel_id)

  def get_channel_invites(channel_id) do
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
          channel :: Channel.t() | snowflake(),
          args :: create_channel_invite_data()
        ) :: {:ok, Invite.t()} | {:error, term()}
  def create_channel_invite(channel, args)

  def create_channel_invite(%Channel{id: channel_id}, args),
    do: create_channel_invite(channel_id, args)

  def create_channel_invite(channel_id, args) do
    Rest.Base.queue(:post, Endpoints.channel(channel_id, "invites"), Map.new(args))
    |> create(Invite)
  end

  @doc """
    Deletes an overwrite from a channel.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#delete-channel-permission).
  """
  @spec delete_channel_permissions(
          channel :: Channel.t() | snowflake(),
          target :: Overwrite.t() | Role.t() | User.t() | Member.t() | snowflake(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def delete_channel_permissions(channel, target, reason \\ nil)

  def delete_channel_permissions(%Channel{id: channel_id}, target, reason),
    do: delete_channel_permissions(channel_id, target, reason)

  def delete_channel_permissions(channel_id, target, reason) do
    with {_type, target_id} <- Util.resolve_overwrite_target(target) do
      Rest.Base.queue(:delete, Endpoints.channel_permissions(channel_id, target_id), %{
        reason: reason
      })
    end
  end

  @doc """
    Gets a list of pinned messages from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/channel#get-pinned-messages).
  """
  @spec get_pinned_messages(channel :: Channel.t() | snowflake()) ::
          {:ok, [Message.t()]} | {:error, term()}
  def get_pinned_messages(channel)

  def get_pinned_messages(%Channel{id: channel_id}), do: get_pinned_messages(channel_id)

  def get_pinned_messages(channel_id) do
    Rest.Base.queue(:get, Endpoints.channel(channel_id, "pins"))
    |> create(Message)
  end

  ### End Channel

  ### Emoji

  @doc """
    Gets a list of emojis in a guild.
    This should usually, duo cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#list-guild-emojis).
  """
  @spec list_guild_emojis(guild :: Guild.t() | snowflake()) ::
          {:ok, [Emoji.t()]} | {:error, term()}
  def list_guild_emojis(guild)
  def list_guild_emojis(%Guild{id: guild_id}), do: list_guild_emojis(guild_id)

  def list_guild_emojis(guild_id) do
    Rest.Base.queue(:get, Endpoints.guild_emojis(guild_id))
    |> create(Emoji)
  end

  @doc """
    Gets an emoji from a guild
    This should usually, duo cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#get-guild-emoji).
  """
  @spec get_guild_emoji(
          guild :: Guild.t() | snowflake(),
          emoji :: snowflake()
        ) :: {:ok, Emoji} | {:error, term()}
  def get_guild_emoji(guild, emoji)
  def get_guild_emoji(%Guild{id: guild_id}, emoji_id), do: get_guild_emoji(guild_id, emoji_id)

  def get_guild_emoji(guild_id, emoji_id) do
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
          guild :: Guild | snowflake(),
          data :: create_guild_emoji_data()
        ) :: {:ok, Emoji} | {:error, term}
  def create_guild_emoji(guild, data)
  def create_guild_emoji(%Guild{id: guild_id}, data), do: create_guild_emoji(guild_id, data)

  def create_guild_emoji(guild_id, data) do
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
            | {:roles, [Role | snowflake]}
            | {:reason, String.t()}
          ]

  @doc """
    Modifies a guild emoji.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji).
  """
  @spec modify_guild_emoji(
          guild :: Guild.t() | snowflake(),
          emoji :: Emoji.t() | snowflake(),
          data :: modify_guild_emoji_data()
        ) :: {:ok, Emoji} | {:error, term()}
  def modify_guild_emoji(guild, emoji, data)

  def modify_guild_emoji(%Guild{id: guild_id}, emoji, data),
    do: modify_guild_emoji(guild_id, emoji, data)

  def modify_guild_emoji(guild_id, %Emoji{id: emoji_id}, data),
    do: modify_guild_emoji(guild_id, emoji_id, data)

  def modify_guild_emoji(guild_id, emoji_id, data) do
    data =
      data
      |> Map.new()
      |> Map.update(:roles, [], &Enum.map(&1, fn role -> Util.resolve_role_id(role) end))

    Rest.Base.queue(:patch, Endpoints.guild_emojis(guild_id, emoji_id), data)
    |> create(Emoji)
  end

  @doc """
    Deletes an emoji from a guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/emoji#delete-guild-emoji).
  """
  @spec delete_guild_emoji(
          guild :: Guild.t() | snowflake(),
          emoji :: Emoji.t() | snowflake(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def delete_guild_emoji(guild, emoji, reason \\ nil)

  def delete_guild_emoji(%Guild{id: guild_id}, emoji, reason),
    do: delete_guild_emoji(guild_id, emoji, reason)

  def delete_guild_emoji(guild_id, %Emoji{id: emoji_id}, reason),
    do: delete_guild_emoji(guild_id, emoji_id, reason)

  def delete_guild_emoji(guild_id, emoji_id, reason) do
    Rest.Base.queue(:delete, Endpoints.guild_emojis(guild_id, emoji_id), %{reason: reason})
  end

  ### End Emoji

  ### Guild

  # @doc, maybe later
  # @spec, yeah no
  # TODO: Well, yeah
  # https://discordapp.com/developers/docs/resources/guild#create-guild
  # ^ worth a read if planing to be used
  def create_guild(data) do
    data =
      data
      |> Map.new()
      |> Map.update(:icon, nil, fn icon ->
        if icon,
          do: with({:ok, binary} <- Util.resolve_file(icon), do: binary |> Base.encode64())
      end)

    Rest.Base.queue(:post, Endpoints.guild(), data)
    |> create(Guild)
  end

  @doc """
    Gets a guild from the api.
    This should usually, duo cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild)
  """
  @spec get_guild(guild :: Guild.t() | snowflake()) :: {:ok, Guild.t()} | {:error, term()}
  def get_guild(guild)
  def get_guild(%Guild{id: guild_id}), do: get_guild(guild_id)

  def get_guild(guild_id) do
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
            optional(:afk_channel_id) => snowflake(),
            optional(:afk_timeout) => non_neg_integer(),
            optional(:icon) => String.t() | binary(),
            optional(:owner_id) => snowflake(),
            optional(:system_channel_id) => snowflake(),
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:region, String.t()}
              | {:verification_level, non_neg_integer()}
              | {:default_message_notifications, non_neg_integer()}
              | {:explicit_content_filter, non_neg_integer()}
              | {:afk_channel_id, snowflake()}
              | {:afk_timeout, non_neg_integer()}
              | {:icon, String.t() | binary()}
              | {:owner_id, snowflake()}
              | {:system_channel_id, snowflake()}
              | {:reason, String.t()}
            ]

  @doc """
    Updates a guild, see `t:modify_guild_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild).
  """
  @spec modify_guild(
          guild :: Guild | snowflake(),
          data :: modify_guild_data()
        ) :: {:ok, Guild} | {:error, term()}
  def modify_guild(guild, data)
  def modify_guild(%Guild{id: guild_id}, data), do: modify_guild(guild_id, data)

  def modify_guild(guild_id, data) do
    data =
      data
      |> Map.new()
      |> Map.update(:icon, nil, fn icon ->
        if icon,
          do: with({:ok, binary} <- Util.resolve_file(icon), do: binary |> Base.encode64())
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
  @spec delete_guild(guild :: Guild.t() | snowflake()) :: :ok | {:error, term()}
  def delete_guild(guild)
  def delete_guild(%Guild{id: guild_id}), do: delete_guild(guild_id)

  def delete_guild(guild_id) do
    Rest.Base.queue(:delete, Endpoints.guild(guild_id))
  end

  @doc """
    Gets all channels from a guild via the api.
    This should usually, duo caching, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-channels)-
  """
  @spec get_guild_channels(guild :: Guild.t() | snowflake()) ::
          {:ok, [Channel.t()]} | {:error, term()}
  def get_guild_channels(guild)
  def get_guild_channels(%Guild{id: guild_id}), do: get_guild_channels(guild_id)

  def get_guild_channels(guild_id) do
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
            optional(:parent_id) => snowflake(),
            optional(:nsfw) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:name, String.t()}
              | {:type, pos_integer()}
              | {:bitrate, non_neg_integer() | nil}
              | {:user_limit, integer() | nil}
              | {:permission_overwrites, [Overwrite.t()]}
              | {:parent_id, snowflake()}
              | {:nsfw, boolean()}
              | {:reason, String.t()}
            ]

  @doc """
    Creates a channel in a guild, see `t:create_guild_channel_data` for available options.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#create-guild-channel).
  """
  @spec create_guild_channel(
          guild :: Guild | snowflake(),
          data :: create_guild_channel_data()
        ) :: {:ok, Channel} | {:error, term()}
  def create_guild_channel(guild, data)
  def create_guild_channel(%Guild{id: guild_id}, data), do: create_guild_channel(guild_id, data)

  def create_guilad_channel(guild_id, data) do
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
          guild :: Guild.t() | snowflake(),
          channels :: [modify_guild_channel_positions_data_entry()]
        ) :: :ok | {:error, term()}
  def modify_guild_channel_positions(guild, channels)

  def modify_guild_channel_positions(%Guild{id: guild_id}, channels),
    do: modify_guild_channel_positions(guild_id, channels)

  def modify_guild_channel_positions(guild_id, channels) do
    channels = Enum.map(channels, &Util.resolve_channel_position/1)

    Rest.Base.queue(:patch, Endpoints.guild(guild_id, "channels"), channels)
  end

  @doc """
    Fetches a member from the api.

    This may be necessary for offline members in large guilds.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#get-guild-member).
  """
  @spec get_guild_member(
          guild :: Guild.t() | snowflake(),
          user :: User.t() | Member.t() | snowflake()
        ) :: {:ok, Member.t()} | {:error, term()}
  def get_guild_member(%Guild{id: guild_id}, user), do: get_guild_member(guild_id, user)
  def get_guild_member(guild_id, %User{id: user_id}), do: get_guild_member(guild_id, user_id)

  def get_guild_member(guild_id, %Member{user: %User{id: user_id}}),
    do: get_guild_member(guild_id, user_id)

  def get_guild_member(guild_id, user_id) do
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
          guild :: Guild.t() | snowflake(),
          options :: list_guild_members_options()
        ) :: {:ok, [Member.t()]} | {:error, term()}

  @doc """
    Gets a list of members from the guild.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#list-guild-members).
  """
  def list_guild_members(guild, options \\ [])
  def list_guild_members(%Guild{id: guild_id}, options), do: list_guild_members(guild_id, options)

  def list_guild_members(guild_id, options) do
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
            optional(:nick) => String.t(),
            optional(:roles) => [snowflake()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:reason) => String.t()
          }
          | [
              {:access_token, String.t()}
              | {:nick, String.t()}
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
          guild :: Guild.t() | snowflake(),
          user :: User.t() | snowflake(),
          data :: add_guild_member_data()
        ) :: {:ok, Member.t()} | {:error, term()}
  def add_guild_member(guild, user, data)

  def add_guild_member(%Guild{id: guild_id}, user, data),
    do: add_guild_member(guild_id, user, data)

  def add_guild_member(guild_id, %User{id: user_id}, data),
    do: add_guild_member(guild_id, user_id, data)

  def add_guild_member(guild_id, user_id, data) do
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
            optional(:nick) => String.t(),
            optional(:roles) => [snowflake()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:channel_id) => snowflake(),
            optional(:reason) => String.t()
          }
          | [
              {:nick, String.t()}
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
          guild :: Guild.t() | snowflake(),
          member_or_user :: Member.t() | User.t() | snowflake(),
          data :: modify_guild_member_data()
        ) :: :ok | {:error, term()}
  def modify_guild_member(guild, member_or_user, data)

  def modify_guild_member(%Guild{id: guild_id}, member_or_user, data),
    do: modify_guild_member(guild_id, member_or_user, data)

  def modify_guild_member(guild_id, %Member{user: user_id}, data),
    do: modify_guild_member(guild_id, user_id, data)

  def modify_guild_member(guild_id, %User{id: user_id}, data),
    do: modify_guild_member(guild_id, user_id, data)

  def modify_guild_member(guild_id, user_id, data) do
    data = Map.new(data)

    Rest.Base.queue(:patch, Endpoints.guild_members(guild_id, user_id), data)
  end

  @doc """
    Modifies the nickname of the current user in a guild.

    Yes you read correctly, that has its own endpoint.

    For more informations, but not an answer to the question why, see [Discord Docs](https://discordapp.com/developers/docs/resources/guild#modify-current-user-nick).
  """
  @spec modify_current_users_nick(
          guild :: Guild.t() | snowflake(),
          nick :: String.t(),
          reason :: String.t()
        ) :: :ok | {:error, term()}
  def modify_current_users_nick(guild, nick, reason \\ nil)

  def modify_current_users_nick(%Guild{id: guild_id}, nick, reason),
    do: modify_current_users_nick(guild_id, nick, reason)

  def modify_current_users_nick(guild_id, nick, reason) do
    Rest.Base.queue(:patch, Endpoints.guild_own_nick(guild_id), %{nick: nick, reason: reason})
  end

  ### End Guild

  @doc """
    Fetches an invite from the api.

    For more informations see [Discord Docs](https://discordapp.com/developers/docs/resources/invite#get-invite).
  """
  @spec get_invite(code :: String.t()) :: {:ok, Invite.t()} | {:error, term()}
  def get_invite(code) do
    Rest.Base.queue(:get, Endpoints.invite(code))
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
