defmodule Crux.Rest do
  @moduledoc """
    Main entry point for `Crux.Rest`.

    For a more convenient way to consume this module you can `use` it in your own.

    Possible `use` options are:
    * `transform` - whether to transform the received JSON further into the documented structs.
      Defaults to `true`.

    ### Example

    ```elixir
    defmodule MyBot.Rest do
      use Crux.Rest

      # Define helper functions as needed
      def gateway_bot_additional_info() do
        with {:ok, data} <- gateway_bot() do
          Map.put(data, "additional_info", MyBot.Additional.info())
        end
      end
    end

    ```

    This module fits under a supervision tree, see `start_link/1`'s' arguments for configuration.
    The same applies to modules `use`-ing this module.
  """

  alias Crux.Rest.{ApiError, Handler, Request, Util, Version}

  alias Crux.Structs.{
    AuditLog,
    Channel,
    Emoji,
    Guild,
    Invite,
    Member,
    Message,
    Overwrite,
    Role,
    Snowflake,
    User,
    Webhook
  }

  require Version

  use Crux.Rest.Gen.Bang, :callbacks

  Version.modulesince("0.1.0")

  @typedoc """
    A Discord snowflake, fits in a 64bit integer.

    Received as integers via the gateway, but as strings via http.

  > They are normalized to integers via `Crux.Structs`.

  > Deprecated: Use `Crux.Snowflake.resolvable()` instead
  """
  Version.typesince("0.1.0")
  @type snowflake :: non_neg_integer()

  ### Message

  @typedoc """
    Used to send messages via `c:create_message/2`.

    The content my not exceed 2000 chars.
    The nonce has to fit in a 64 bit integer or be a string.
    The whole message payload may not be larger than 8mb, this should only be possible when attaching (a) large file(s).
    Exception to this rule are boosted guilds where the limit may differ.
  """
  Version.typesince("0.1.0")

  @type create_message_data ::
          %{
            optional(:content) => String.t(),
            optional(:nonce) => String.t() | integer(),
            optional(:tts) => boolean(),
            optional(:embed) => embed(),
            optional(:files) => [Util.attachment()]
          }
          | [
              {:content, String.t()}
              | {:nonce, String.t() | integer()}
              | {:tts, boolean()}
              | {:embed, embed()}
              | {:files, [Util.attachment()]}
            ]

  @typedoc """
    Used to send and embed via `c:create_message/2`.

    You should probably consult the [Embed Limits](https://discord.com/developers/docs/resources/channel#embed-limits) page.
  """
  Version.typesince("0.1.0")

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

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#create-message)
  """
  Version.since("0.2.0")

  @callback create_message(
              channel :: Channel.id_resolvable(),
              args :: Crux.Rest.create_message_data()
            ) :: {:ok, Message.t()} | {:error, term()}

  @typedoc """
    Used to edit messages via `c:edit_message/2` or `c:edit_message/3`.

    The content my not exceed 2000 chars, this limit is enfored on discord's end.
  """
  Version.typesince("0.1.0")

  @type message_edit_data ::
          %{
            optional(:content) => String.t() | nil,
            optional(:embed) => embed() | nil,
            optional(:flags) => non_neg_integer()
          }
          | [{:content, String.t()} | {:embed, embed()}]

  @doc """
  Edits a message.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#edit-message).
  """
  Version.since("0.2.0")

  @callback edit_message(
              target :: Message.t(),
              args :: Crux.Rest.message_edit_data()
            ) :: {:ok, Message.t()} | {:error, term()}

  @doc """
  Edits a message.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#edit-message).
  """

  Version.since("0.2.0")

  @callback edit_message(
              channel_id :: Channel.id_resolvable(),
              message_id :: Message.id_resolvable(),
              args :: Crux.Rest.message_edit_data()
            ) :: {:ok, Message.t()} | {:error, term()}

  @doc """
    Deletes a message

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-message).
  """
  Version.since("0.2.0")

  @callback delete_message(message :: Message.t()) :: :ok | {:error, term()}

  @doc """
    Deletes a message

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-message).
  """
  Version.since("0.2.0")

  @callback delete_message(
              channel_id :: Channel.id_resolvable(),
              message_id :: Message.id_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Deletes 2-100 messages not older than 14 days.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#bulk-delete-messages)
  """
  Version.since("0.2.0")

  @callback delete_messages(
              channel :: Channel.id_resolvable(),
              messages :: [Message.id_resolvable()]
            ) :: :ok | {:error, term()}

  @doc """
    Gets a message from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-channel-message).
  """
  Version.since("0.2.0")

  @callback get_message(
              channel :: Channel.id_resolvable(),
              message_id :: Message.id_resolvable()
            ) :: {:ok, Message.t()} | {:error, term()}

  @typedoc """
    Used to get messages from the api via `c:get_messages/2`.

    Notes:
  * `:around` is inclusive
  * `:before` and `:after` are exclusive
  * `:limit` has to be [1-100], defaults to 50
  """
  Version.typesince("0.1.0")

  @type get_messages_data ::
          %{
            optional(:around) => Message.id_resolvable(),
            optional(:before) => Message.id_resolvable(),
            optional(:after) => Message.id_resolvable(),
            optional(:limit) => pos_integer()
          }
          | [
              {:around, Message.id_resolvable()}
              | {:before, Message.id_resolvable()}
              | {:after, Message.id_resolvable()}
              | {:limit, pos_integer()}
            ]

  @doc """
  Gets 1-100 messages from the api, this limit is enforced on discord's end.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-channel-messages).
  """
  Version.since("0.2.0")

  @callback get_messages(
              channel :: Channel.id_resolvable(),
              args :: Crux.Rest.get_messages_data()
            ) :: {:ok, %{required(Snowflake.t()) => Message.t()}} | {:error, term()}

  ### End Message

  ### Reaction

  @doc """
  Creates a reaction on a message, or increases its count by one.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#create-reaction).
  """
  Version.since("0.2.0")

  @callback create_reaction(
              message :: Message.id_resolvable(),
              emoji :: Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
  Creates a reaction on a message, or increases its count by one.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#create-reaction).
  """
  Version.since("0.2.0")

  @callback create_reaction(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable(),
              emoji :: Emoji.id_resolvable()
            ) :: :ok | {:error, term()}

  @typedoc """
    Used to get more specific users who reacted to a message from the api via `c:get_reactions/4`

    Notes:
    * `:before` seems currently broken on discord's end
    * `:after` is exclusive
  """
  Version.typesince("0.1.0")

  @type get_reactions_data ::
          %{
            optional(:before) => User.id_resolvable(),
            optional(:after) => User.id_resolvable(),
            optional(:limit) => pos_integer()
          }
          | [
              {:before, User.id_resolvable()}
              | {:after, User.id_resolvable()}
              | {:limit, pos_integer()}
            ]

  @doc """
    Gets users who reacted to a message.

    The first argument is optional if a `Crux.Structs.Message` is provided.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-reactions).
  """
  Version.since("0.2.0")

  @callback get_reactions(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable(),
              emoji :: Emoji.identifier_resolvable() | list(),
              args :: Crux.Rest.get_reactions_data()
            ) :: {:ok, %{required(Snowflake.t()) => User.t()}} | {:error, term()}

  Version.since("0.2.0")

  @callback get_reactions(
              message :: Message.t(),
              emoji :: Emoji.identifier_resolvable(),
              args :: Crux.Rest.get_reactions_data()
            ) :: {:ok, %{required(Snowflake.t()) => User.t()}} | {:error, term()}

  @doc """
    Deletes a user from a reaction.

    The first argument is optional if a `Crux.Structs.Message` is provided.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-own-reaction) [2](https://discord.com/developers/docs/resources/channel#delete-user-reaction).
  """
  Version.since("0.2.0")

  @callback delete_reaction(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable(),
              emoji :: Emoji.identifier_resolvable(),
              user :: User.id_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Deletes all reactions from a message.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-all-reactions).
  """
  Version.since("0.2.0")

  @callback delete_all_reactions(
              message :: Message.t(),
              emoji :: Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Deletes all reactions from a message.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-all-reactions).
  """
  Version.since("0.2.0")

  @callback delete_all_reactions(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable(),
              emoji :: Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

  ### End Reactions

  ### Channel

  @doc """
    Lets the bot appear as typing for roughly ~9 seconds or until a message is sent.
    Should generally be used sparingly for commands that may take a while as a form of acknowledging.

    Consider sending a message and edit that later on instead.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#trigger-typing-indicator).
  """
  Version.since("0.2.0")
  @callback trigger_typing(channel :: Channel.id_resolvable()) :: :ok | {:error, term()}

  @doc """
    Adds a message to the pinned messages of a channel.

    You may only have up to 50 pinned messages per channel.
    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#add-pinned-channel-message).
  """
  Version.since("0.2.0")

  @callback add_pinned_message(message :: Message.t()) :: :ok | {:error, term()}

  @doc """
    Adds a message to the pinned messages of a channel.

    You may only have up to 50 pinned messages per channel.
    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#add-pinned-channel-message).
  """
  Version.since("0.2.0")

  @callback add_pinned_message(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Deletes a message from the pinned messages. This does not delete the message itself.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-pinned-channel-message).
  """
  Version.since("0.2.0")

  @callback delete_pinned_message(message :: Message.t()) :: :ok | {:error, term()}

  @doc """
    Deletes a message from the pinned messages. This does not delete the message itself.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-pinned-channel-message).
  """
  Version.since("0.2.0")

  @callback delete_pinned_message(
              channel :: Channel.id_resolvable(),
              message :: Message.id_resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Gets a channel from the api.
    This should _NOT_ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-channel)
  """
  Version.since("0.2.0")

  @callback get_channel(channel :: Channel.id_resolvable()) ::
              {:ok, Channel.t()} | {:error, term()}

  @typedoc """
    Used to modify a channel via `c:modify_channel/2`.

    Notes
  * `:name` has to be [2-100] chars long.
  * `:topic` has to be [0-1024] chars long
  * `:bitrate` is in bits [8_000-96_000] (128_000 for VIP servers)
  * `:user_limit` has to be [0-99], 0 refers to no limit
  * `:rate_limit_per_user` has to be [0-120], 0 refers to no limit

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#modify-channel-json-params).
  """
  Version.typesince("0.1.0")

  @type modify_channel_data ::
          %{
            optional(:bitrate) => non_neg_integer(),
            optional(:icon) => Util.image(),
            optional(:name) => String.t() | nil,
            optional(:nsfw) => boolean(),
            optional(:parent_id) => Channel.id_resolvable() | nil,
            optional(:permission_overwrites) => [Overwrite.t()],
            optional(:position) => non_neg_integer(),
            optional(:rate_limit_per_user) => non_neg_integer(),
            optional(:reason) => String.t() | nil,
            optional(:topic) => String.t() | nil,
            optional(:user_limit) => non_neg_integer() | nil
          }
          | [
              {:bitrate, non_neg_integer()}
              | {:icon, Util.image()}
              | {:name, String.t() | nil}
              | {:nsfw, boolean()}
              | {:parent_id, Channel.id_resolvable() | nil}
              | {:permission_overwrites, [Overwrite.t()]}
              | {:position, non_neg_integer()}
              | {:rate_limit_per_user, non_neg_integer()}
              | {:reason, String.t() | nil}
              | {:topic, String.t() | nil}
              | {:user_limit, integer() | nil}
            ]

  @doc """
    Modifies a channel, see `t:Crux.Rest.modify_channel_data/0` for available options.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#modify-channel).
  """
  Version.since("0.2.0")

  @callback modify_channel(
              channel :: Channel.id_resolvable(),
              data :: Crux.Rest.modify_channel_data()
            ) :: {:ok, Channel.t()} | {:error, term()}

  @doc """
    Deletes a channel.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#deleteclose-channel).
  """
  Version.since("0.2.0")

  @callback delete_channel(
              channel :: Channel.id_resolvable(),
              reason :: String.t() | nil
            ) :: {:ok, Channel.t()} | {:error, term()}

  @typedoc """
    Used to edit overwrites for a role or member with `c:edit_channel_permissions/3`

    See [Permissions](https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags) for available bitflags.
  """
  Version.typesince("0.1.0")

  @type edit_channel_permissions_data ::
          %{
            optional(:allow) => non_neg_integer(),
            optional(:deny) => non_neg_integer(),
            optional(:type) => String.t(),
            optional(:reason) => String.t() | nil
          }
          | [
              {:allow, non_neg_integer()}
              | {:deny, non_neg_integer()}
              | {:type, :member | :role | String.t()}
              | {:reason, String.t() | nil}
            ]

  @doc """
  Edits or creates an overwrite for a user, or member.

  If an id is provided for `:target`, `:type` must be specified in `t:Crux.Rest.edit_channel_permissions_data/0`.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#edit-channel-permissions).
  """
  Version.since("0.2.0")

  @callback edit_channel_permissions(
              channel :: Channel.id_resolvable(),
              target :: Overwrite.target_resolvable(),
              data :: Crux.Rest.edit_channel_permissions_data()
            ) :: :ok | {:error, :missing_target} | {:error, term()}

  @doc """
    Gets invites for the specified channel from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-channel-invites)
  """
  Version.since("0.2.0")

  @callback get_channel_invites(channel :: Channel.id_resolvable()) ::
              {:ok, %{required(String.t()) => Invite.t()}} | {:error, term()}

  @typedoc """
    Used to create invites via `c:create_channel_invite/2`.

    Notes:
    * `:max_age` 0 indicates no max age, defaults to 86_400 (1 day)
    * `:max_uses` 0 indicates no max uses, defaults to 0
    * `:temporary` if true, members which do not get a role assigned within 24 hours get automatically kicked, defaults to false
    * `:unique` if true, always creates a new invite instead of maybe returning a similar one, defaults to false

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#create-channel-invite-json-params).
  """
  Version.typesince("0.1.0")

  @type create_channel_invite_data ::
          %{
            optional(:max_age) => non_neg_integer(),
            optional(:max_uses) => non_neg_integer(),
            optional(:temporary) => boolean(),
            optional(:unique) => boolean(),
            optional(:reason) => String.t() | nil
          }
          | [
              {:max_age, non_neg_integer()}
              | {:max_uses, non_neg_integer()}
              | {:temporary, boolean()}
              | {:unique, boolean()}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Creates an invite to a channel, see `t:Crux.Rest.create_channel_invite_data/0` for available options.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#create-channel-invite).
  """
  Version.since("0.2.0")

  @callback create_channel_invite(
              channel :: Channel.id_resolvable(),
              args :: Crux.Rest.create_channel_invite_data()
            ) :: {:ok, Invite.t()} | {:error, term()}

  @doc """
    Deletes an overwrite from a channel.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#delete-channel-permission).
  """
  Version.since("0.2.0")

  @callback delete_channel_permissions(
              channel :: Channel.id_resolvable(),
              target :: Overwrite.target_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Gets a list of pinned messages from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/channel#get-pinned-messages).
  """
  Version.since("0.2.0")

  @callback get_pinned_messages(channel :: Channel.id_resolvable()) ::
              {:ok, %{required(Snowflake.t()) => Message.t()}} | {:error, term()}

  ### End Channel

  ### Emoji

  @doc """
    Gets a list of emojis in a guild.
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/emoji#list-guild-emojis).
  """
  Version.since("0.2.0")

  @callback list_guild_emojis(guild :: Guild.id_resolvable()) ::
              {:ok, %{required(Snowflake.t()) => Emoji.t()}} | {:error, term()}

  @doc """
    Gets an emoji from a guild
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/emoji#get-guild-emoji).
  """
  Version.since("0.2.0")

  @callback get_guild_emoji(
              guild :: Guild.id_resolvable(),
              emoji :: Emoji.id_resolvable()
            ) :: {:ok, Emoji} | {:error, term()}

  @typedoc """
    Used to create emojis via `c:create_guild_emoji/2`.

    Notes:
    * `:name` has to be [1-32] chars long, valid chars are [a-Z_0-9] (invalid chars may get filtered out instead of erroring).
        A 1 char long name gets suffixed with `_` to be 2 chars long.
    * `:image` may not be larger than 256kb
    * `:roles`, if present limits the emoji to only those roles
  """
  Version.typesince("0.1.0")

  @type create_guild_emoji_data ::
          %{
            required(:name) => String.t(),
            required(:image) => Util.image(),
            optional(:roles) => [Role.id_resolvable()],
            optional(:reason) => String.t() | nil
          }
          | [
              {:name, String.t()}
              | {:image, Util.image()}
              | {:roles, [Role.id_resolvable()]}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Creates an emoji in a guild, see `t:Crux.Rest.create_guild_emoji_data/0` for available options.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/emoji#create-guild-emoji).
  """
  Version.since("0.2.0")

  @callback create_guild_emoji(
              guild :: Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_emoji_data()
            ) :: {:ok, Emoji} | {:error, term}

  @typedoc """
   Used to modify a guild emoji via `c:modify_guild_emoji/3`.

   See `t:Crux.Rest.create_guild_emoji_data/0` for name restrictions.
  """
  Version.typesince("0.1.0")

  @type modify_guild_emoji_data ::
          %{
            optional(:name) => String.t(),
            optional(:roles) => [Role.id_resolvable()],
            optional(:reason) => String.t() | nil
          }
          | [
              {:name, String.t()}
              | {:roles, [Role.id_resolvable()]}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Modifies a guild emoji.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/emoji#modify-guild-emoji).
  """
  Version.since("0.2.0")

  @callback modify_guild_emoji(
              guild :: Guild.id_resolvable(),
              emoji :: Emoji.id_resolvable(),
              data :: Crux.Rest.modify_guild_emoji_data()
            ) :: {:ok, Emoji} | {:error, term()}

  @doc """
    Deletes an emoji from a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/emoji#delete-guild-emoji).
  """
  Version.since("0.2.0")

  @callback delete_guild_emoji(
              guild :: Guild.id_resolvable(),
              emoji :: Emoji.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  ### End Emoji

  ### Guild

  Version.since("0.2.0")
  @callback create_guild(term()) :: {:ok, Guild.t()} | {:error, term()}

  @doc """
    Gets a guild from the api.
    This should usually, due to cache, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild)
  """
  Version.since("0.2.0")
  @callback get_guild(guild :: Guild.id_resolvable()) :: {:ok, Guild.t()} | {:error, term()}

  @typedoc """
    Used to modify a guild using `c:modify_guild/2`.
  """
  Version.typesince("0.1.0")

  @type modify_guild_data ::
          %{
            optional(:name) => String.t(),
            optional(:region) => String.t(),
            optional(:verification_level) => non_neg_integer(),
            optional(:default_message_notifications) => non_neg_integer(),
            optional(:explicit_content_filter) => non_neg_integer(),
            optional(:afk_channel_id) => Channel.id_resolvable() | nil,
            optional(:afk_timeout) => non_neg_integer(),
            optional(:icon) => Util.image(),
            optional(:splash) => Util.image(),
            optional(:banner) => Util.image(),
            optional(:owner_id) => User.id_resolvable(),
            optional(:system_channel_id) => Channel.id_resolvable() | nil,
            optional(:reason) => String.t() | nil
          }
          | [
              {:name, String.t()}
              | {:region, String.t()}
              | {:verification_level, non_neg_integer()}
              | {:default_message_notifications, non_neg_integer()}
              | {:explicit_content_filter, non_neg_integer()}
              | {:afk_channel_id, Channel.id_resolvable() | nil}
              | {:afk_timeout, non_neg_integer()}
              | {:icon, Util.image()}
              | {:splash, Util.image()}
              | {:banner, Util.image()}
              | {:owner_id, User.id_resolvable()}
              | {:system_channel_id, Channel.id_resolvable() | nil}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Updates a guild, see `t:Crux.Rest.modify_guild_data/0` for available options.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild).
  """
  Version.since("0.2.0")

  @callback modify_guild(
              guild :: Guild.id_resolvable(),
              data :: Crux.Rest.modify_guild_data()
            ) :: {:ok, Guild.t()} | {:error, term()}

  @doc """
    Deletes a guild, can only be used if the executing user is the owner of the guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#delete-guild).
  """
  Version.since("0.2.0")
  @callback delete_guild(guild :: Guild.id_resolvable()) :: :ok | {:error, term()}

  @typedoc """
    Used to filter audit log results via `c:get_audit_logs/2`.
    The `:user_id` field refers to the executor and not the target of the log.
  """
  Version.typesince("0.1.7")

  @type audit_log_options ::
          %{
            optional(:user_id) => User.id_resolvable(),
            optional(:action_type) => pos_integer(),
            optional(:before) => User.id_resolvable(),
            optional(:limit) => pos_integer()
          }
          | [
              {:user_id, User.id_resolvable()}
              | {:action_type, pos_integer()}
              | {:before, User.id_resolvable()}
              | {:limit, pos_integer}
            ]

  @doc """
    Gets the audit logs for a guild
  """
  Version.since("0.2.0")

  @callback get_audit_logs(
              guild :: Guild.id_resolvable(),
              options :: Crux.Rest.audit_log_options() | nil
            ) :: {:ok, AuditLog.t()} | {:error, term()}

  @doc """
    Gets all channels from a guild via the api.
    This should usually, due to caching, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-channels)-
  """
  Version.since("0.2.0")

  @callback get_guild_channels(guild :: Guild.id_resolvable()) ::
              {:ok, %{required(Snowflake.t()) => Channel.t()}} | {:error, term()}

  @typedoc """
    Used to create a channel via `c:create_guild_channel/2`.

    Notes:
   * `:name` has to be [2-100] chars and may only contain [a-Z_-]
  """
  Version.typesince("0.1.0")

  @type create_guild_channel_data ::
          %{
            optional(:name) => String.t(),
            optional(:type) => non_neg_integer(),
            optional(:bitrate) => non_neg_integer() | nil,
            optional(:user_limit) => integer() | nil,
            optional(:permission_overwrites) => [
              Overwrite.t()
              | %{
                  required(:id) => Role.id_resolvable() | Channel.id_resolvable(),
                  required(:type) => String.t(),
                  optional(:allow) => non_neg_integer(),
                  optional(:deny) => non_neg_integer()
                }
            ],
            optional(:parent_id) => Channel.id_resolvable() | nil,
            optional(:nsfw) => boolean(),
            optional(:reason) => String.t() | nil
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
                       required(:id) => Role.id_resolvable() | Channel.id_resolvable(),
                       required(:type) => String.t(),
                       optional(:allow) => non_neg_integer(),
                       optional(:deny) => non_neg_integer()
                     }
                 ]}
              | {:parent_id, Channel.id_resolvable() | nil}
              | {:nsfw, boolean()}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Creates a channel in a guild, see `t:Crux.Rest.create_guild_channel_data/0` for available options.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#create-guild-channel).
  """
  Version.since("0.2.0")

  @callback create_guild_channel(
              guild :: Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_channel_data()
            ) :: {:ok, Channel.t()} | {:error, term()}

  @typedoc """
    Used to change a channel's position via `c:modify_guild_channel_positions/2`.

  > Deprecated: Use `Crux.Structs.Channel.position_resolvable()` instead
  """
  Version.typesince("0.1.0")

  @type modify_guild_channel_positions_data_entry :: Channel.position_resolvable()

  @doc """
    Modifyies the position of a list of channels in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions).
  """
  Version.since("0.2.0")

  @callback modify_guild_channel_positions(
              guild :: Guild.id_resolvable(),
              channels :: [Channel.position_resolvable()]
            ) :: :ok | {:error, term()}

  @doc """
    Gets a member from the api.

    This may be necessary for offline members in large guilds.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-member).
  """
  Version.since("0.2.0")

  @callback get_guild_member(
              guild :: Guild.id_resolvable(),
              user :: User.id_resolvable()
            ) :: {:ok, Member.t()} | {:error, term()}

  @typedoc """
    Used to list guild members via `c:list_guild_members/2`.
  """
  Version.typesince("0.1.0")

  @type list_guild_members_options ::
          %{
            optional(:limit) => pos_integer(),
            optional(:after) => User.id_resolvable()
          }
          | [{:limit, pos_integer()} | {:after, User.id_resolvable()}]

  @doc """
    Gets a list of members from the guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#list-guild-members).
  """
  Version.since("0.2.0")

  @callback list_guild_members(
              guild :: Guild.id_resolvable(),
              options :: Crux.Rest.list_guild_members_options()
            ) :: {:ok, %{required(Snowflake.t()) => Member.t()}} | {:error, term()}

  @typedoc """
    Used to add a member to a guild via `c:add_guild_member/3`.
  """
  Version.typesince("0.1.0")

  @type add_guild_member_data ::
          %{
            required(:access_token) => String.t(),
            optional(:nick) => String.t() | nil,
            optional(:roles) => [Role.id_resolvable()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:reason) => String.t() | nil
          }
          | [
              {:access_token, String.t()}
              | {:nick, String.t() | nil}
              | {:roles, [Role.id_resolvable()]}
              | {:mute, boolean()}
              | {:deaf, boolean()}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Adds a user to a guild via a provided oauth2 access token with the [`guilds.join`](https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes) scope.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#add-guild-member).
  """
  Version.since("0.2.0")

  @callback add_guild_member(
              guild :: Guild.id_resolvable(),
              user :: User.id_resolvable(),
              data :: Crux.Rest.add_guild_member_data()
            ) :: {:ok, Member.t()} | {:error, term()}

  @typedoc """
    Used to modify a member with `c:modify_guild_member/3`.

    Notes:
    - A `nil` `:channel_id` will kick the member from the voice channel.
  """
  Version.typesince("0.1.0")

  @type modify_guild_member_data ::
          %{
            optional(:nick) => String.t() | nil,
            optional(:roles) => [Role.id_resolvable()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean(),
            optional(:channel_id) => Channel.id_resolvable() | nil,
            optional(:reason) => String.t() | nil
          }
          | [
              {:nick, String.t() | nil}
              | {:roles, [Role.id_resolvable()]}
              | {:mute, boolean()}
              | {:deaf, boolean()}
              | {:channel_id, Channel.id_resolvable() | nil}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Modifies a member in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-member).
  """
  Version.since("0.2.0")

  @callback modify_guild_member(
              guild :: Guild.id_resolvable(),
              member :: User.id_resolvable(),
              data :: Crux.Rest.modify_guild_member_data()
            ) :: :ok | {:error, term()}

  @doc """
    Modifies the nickname of the current user in a guild.

    Yes, you read correctly, that has its own endpoint.
    Great, isn't it?

    For more informations, but not an answer to the question why, see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-current-user-nick).
  """
  Version.since("0.2.0")

  @callback modify_current_users_nick(
              guild :: Guild.id_resolvable(),
              nick :: String.t(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Adds a role to a member.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#add-guild-member-role).
  """
  Version.since("0.2.0")

  @callback add_guild_member_role(
              guild :: Guild.id_resolvable(),
              member :: User.id_resolvable(),
              role :: Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Removes a role from a member.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#remove-guild-member-role).
  """
  Version.since("0.2.0")

  @callback remove_guild_member_role(
              guild :: Guild.id_resolvable(),
              member :: User.id_resolvable(),
              role :: Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Gets a map of banned users along their ban reasons.

    For more informations see [discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-bans).
  """
  Version.since("0.2.0")

  @callback get_guild_bans(guild :: Guild.id_resolvable()) ::
              {:ok, %{Snowflake.t() => %{user: User.t(), reason: String.t() | nil}}}
              | {:error, term()}

  @doc """
    Gets a single ban entry by id.

  > Returns {:error, %Crux.Rest.ApiError{status_code: 404, code: 10026, ...}} when the user is not banned.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-ban).
  """
  Version.since("0.2.0")

  @callback get_guild_ban(guild :: Guild.id_resolvable(), user :: User.id_resolvable()) ::
              {:ok, %{user: User.t(), reason: String.t() | nil}} | {:error, term()}

  @doc """
    Bans a user from a guild; The user does not have to be part of the guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#create-guild-ban).
  """
  Version.since("0.2.0")

  @callback create_guild_ban(
              guild :: Guild.id_resolvable(),
              user :: User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Removes a ban for a user from a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#remove-guild-ban).
  """
  Version.since("0.2.0")

  @callback remove_guild_ban(
              guild :: Guild.id_resolvable(),
              user :: User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Gets a list of roles in a guild.
    This should usually, due to caching, __NOT__ be necessary.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-roles).
  """
  Version.since("0.2.0")

  @callback get_guild_roles(guild :: Guild.id_resolvable()) ::
              {:ok, %{Snowflake.t() => Role.t()}} | {:error, term()}

  @typedoc """
    Used to create a role in a guild with `c:create_guild_role/2`.
  """
  Version.typesince("0.1.2")

  @type guild_role_data ::
          %{
            optional(:name) => String.t(),
            optional(:permissions) => non_neg_integer(),
            optional(:color) => non_neg_integer(),
            optional(:hoist) => boolean(),
            optional(:mentionable) => boolean(),
            optional(:reason) => String.t() | nil
          }
          | [
              {:name, String.t()}
              | {:permissions, non_neg_integer()}
              | {:color, non_neg_integer()}
              | {:hoist, boolean()}
              | {:mentionable, boolean()}
              | {:reason, String.t() | nil}
            ]

  @doc """
    Creates a role in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#create-guild-role).
  """
  Version.since("0.2.0")

  @callback create_guild_role(
              guild :: Guild.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: {:ok, Role.t()} | {:error, term()}

  @doc """
    Modifies the positions of a list of role objects for a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-role-positions).
  """
  Version.since("0.2.0")

  @callback modify_guild_role_positions(
              guild :: Guild.id_resolvable(),
              data :: [Role.position_resolvable()]
            ) :: {:ok, %{Snowflake.t() => Role.t()}} | {:error, term()}

  @doc """
    Modifies a role in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-role).
  """
  Version.since("0.2.0")

  @callback modify_guild_role(
              guild :: Guild.id_resolvable(),
              role :: Role.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: {:ok, Role.t()} | {:error, term()}

  @doc """
  Deletes a role in a guild.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#delete-guild-role).
  """
  Version.since("0.2.0")

  @callback delete_guild_role(
              guild :: Guild.id_resolvable(),
              role :: Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

  @doc """
    Gets the number of members in a guild that would be removed when pruned.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-prune-count).
  """
  Version.since("0.2.0")

  @callback get_guild_prune_count(guild :: Guild.id_resolvable(), days :: pos_integer()) ::
              {:ok, non_neg_integer()} | {:error, term()}

  @typedoc """
    Used to prune inactive guild members with `c:begin_guild_prune/2`.
  """
  Version.typesince("0.2.0")

  @type begin_guild_prune_opts ::
          %{
            optional(:days) => pos_integer(),
            optional(:compute_prune_count) => boolean()
          }
          | [{:days, pos_integer()} | {:compute_prune_count, boolean()}]

  @doc """
    Prunes members in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#begin-guild-prune).
  """
  Version.since("0.2.0")

  @callback begin_guild_prune(
              guild :: Guild.id_resolvable(),
              opts :: Crux.Rest.begin_guild_prune_opts()
            ) :: {:ok, non_neg_integer()} | {:error, term()}

  @doc """
    Gets a list of voice regions for a guild. Returns VIP servers when the guild is VIP-enabled.

  > Returns a list of [Voice Region Objects](https://discord.com/developers/docs/resources/voice#voice-region-object).

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-voice-regions).
  """
  Version.since("0.2.0")

  @callback get_guild_voice_regions(guild :: Guild.id_resolvable()) ::
              {:ok, term()} | {:error, term()}

  @doc """
    Gets all available invites in a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-invites).
  """
  Version.since("0.2.0")

  @callback get_guild_invites(guild :: Guild.id_resolvable()) ::
              {:ok, %{String.t() => Invite.t()}} | {:error, term()}

  @doc """
    Gets a list of guild integrations.

  > Returns a list of [Integration Objects](https://discord.com/developers/docs/resources/guild#integration-object).

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-integration).
  """
  Version.since("0.2.0")

  @callback get_guild_integrations(guild :: Guild.id_resolvable()) ::
              {:ok, list()} | {:error, term()}

  @doc """
    Attaches an integration from the current user to a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#create-guild-integration).
  """
  Version.since("0.2.0")

  @callback create_guild_integration(
              guild :: Guild.id_resolvable(),
              data ::
                %{type: String.t(), id: Snowflake.resolvable()}
                | [{:type, String.t()} | {:id, Snowflake.resolvable()}]
            ) :: :ok | {:error, term()}

  @doc """
    Modifies an integreation for a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-integration).
  """
  Version.since("0.2.0")

  @callback modify_guild_integration(
              guild :: Guild.id_resolvable(),
              integration_id :: Snowflake.resolvable(),
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

  @doc """
    Deletes an integration from a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#delete-guild-integration).
  """
  Version.since("0.2.0")

  @callback delete_guild_integration(
              guild :: Guild.id_resolvable(),
              integration_id :: Snowflake.resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Syncs an integration for a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#sync-guild-integration).
  """
  Version.since("0.2.0")

  @callback sync_guild_integration(
              guild :: Guild.id_resolvable(),
              integration_id :: Snowflake.resolvable()
            ) :: :ok | {:error, term()}

  @doc """
    Gets a guild's embed (server widget).

  > Returns a [Guild Embed Object](https://discord.com/developers/docs/resources/guild#guild-embed-object).

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#get-guild-embed).
  """
  Version.since("0.2.0")

  @callback get_guild_embed(guild :: Guild.id_resolvable()) ::
              {:ok, term()} | {:error, term()}

  @doc """
    Modifies a guild's embed (server widget).

  > Returns the updated [Guild Embed Object](https://discord.com/developers/docs/resources/guild#guild-embed-object).

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/guild#modify-guild-embed).
  """
  Version.since("0.2.0")

  @callback modify_guild_embed(
              guild :: Guild.id_resolvable(),
              data ::
                %{
                  optional(:enabled) => boolean(),
                  optional(:channel_id) => Channel.id_resolvable()
                }
                | [{:enabled, boolean()} | {:channel_id, Channel.id_resolvable()}]
            ) :: {:ok, term()} | {:error, term()}

  @doc """
    Gets the vanity url of a guild, if any
  """
  Version.since("0.2.0")
  Version.deprecated("Use get_guild_vanity_invite/1 instead")

  @callback get_guild_vanity_url(guild :: Guild.id_resolvable()) ::
              {:ok, String.t()} | {:error, term()}

  @doc """
    Gets the vanity invite of a guild, if any
  """
  Version.since("0.2.1")

  @callback get_guild_vanity_invite(guild :: Guild.id_resolvable()) ::
              {:ok, Invite.t()} | {:error, term()}

  ### End Guild

  ### Start Webhook

  @doc """
    Gets a guild's webhook list

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#get-guild-webhooks)
  """
  Version.since("0.2.0")

  @callback list_guild_webhooks(guild :: Guild.id_resolvable()) ::
              {:ok, %{required(Snowflake.t()) => Webhook.t()}} | {:error, term()}

  @doc """
    Gets a channel's webhook list

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#get-channel-webhooks)
  """
  Version.since("0.2.0")

  @callback list_channel_webhooks(channel :: Channel.id_resolvable()) ::
              {:ok, %{required(Snowflake.t()) => Webhook.t()}} | {:error, term()}

  @doc """
    Gets a webhook

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#get-webhook)
  """
  Version.since("0.2.0")

  @callback get_webhook(user :: User.id_resolvable(), token :: String.t() | nil) ::
              {:ok, Webhook.t()} | {:error, term()}

  @doc """
    Updates a webhook

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#modify-webhook)
  """
  Version.since("0.2.0")

  @callback update_webhook(
              user :: User.id_resolvable(),
              token :: String.t() | nil,
              data ::
                %{
                  optional(:name) => String.t(),
                  optional(:avatar) => Util.image(),
                  optional(:channel_id) => Channel.id_resolvable()
                }
                | [
                    {:name, String.t()}
                    | {:avatar, Util.image()}
                    | {:channel_id, Channel.id_resolvable()}
                  ]
            ) :: {:ok, Webhook.t()} | {:error, term()}

  @doc """
    Deletes a webhook

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#delete-webhook)
  """
  Version.since("0.2.0")

  @callback delete_webhook(user :: User.id_resolvable(), token :: String.t() | nil) ::
              :ok | {:error, term()}

  @typedoc """
    Used for sending discord webhooks. For more information on non-discord webhooks, check
    [Slack Docs](https://api.slack.com/custom-integrations/outgoing-webhooks) or
    [Github Docs](https://developer.github.com/webhooks/)
  """
  Version.typesince("0.1.7")

  @type execute_webhook_options :: %{
          optional(:content) => String.t(),
          optional(:username) => String.t(),
          optional(:avatar_url) => String.t(),
          optional(:tts) => boolean(),
          optional(:files) => [Util.attachment()],
          optional(:embeds) => [embed()]
        }

  @doc """
    Executes a webhook

  > Returns :ok by default. If wait parameter is set to true, returns a tuple returning the message object or error

    For more information see [Discord Docs](https://discord.com/developers/docs/resources/webhook#execute-webhook)
  """
  Version.since("0.2.0")

  @callback execute_webhook(
              webhook :: Webhook.t(),
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok
  Version.since("0.2.0")

  @callback execute_webhook(
              webhook :: Webhook.t(),
              wait :: boolean() | nil,
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok | {:ok, Message.t()} | {:error, term()}
  Version.since("0.2.0")

  @callback execute_webhook(
              user :: User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok | {:ok, Message.t()} | {:error, term()}

  @doc """
    Executes a slack webhook

  > Returns :ok by default. If wait parameter is set to true, it will either return :ok or an error tuple. Discord does not return the message object unlike the regular webhook endpoint.

    For more information see [Slack Docs](https://api.slack.com/custom-integrations/outgoing-webhooks)
  """
  Version.since("0.2.0")

  @callback execute_slack_webhook(webhook :: Webhook.t(), data :: term()) :: :ok
  Version.since("0.2.0")

  @callback execute_slack_webhook(
              webhook :: Webhook.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term()}
  Version.since("0.2.0")

  @callback execute_slack_webhook(
              user :: User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term()}

  @doc """
    Executes a github webhook

  > Returns :ok by default. If wait parameter is set to true, it will either return :ok or an error tuple. Discord does not return the message object unlike the regular webhook endpoint.

    The event parameter is passed into the "x-github-event" header. If this is not set to a valid event (e.g, "push", "issue"), discord will not send the webhook but still return 204 OK

    For more information see [Github Docs](https://developer.github.com/webhooks/)
  """
  Version.since("0.2.0")

  @callback execute_github_webhook(webhook :: Webhook.t(), event :: String.t(), data :: term()) ::
              :ok

  Version.since("0.2.0")

  @callback execute_github_webhook(
              webhook :: Webhook.t(),
              event :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term}
  Version.since("0.2.0")

  @callback execute_github_webhook(
              user :: User.id_resolvable(),
              token :: String.t(),
              event :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term}

  ### End Webhook

  @doc """
    Gets an invite from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/invite#get-invite).
  """
  Version.since("0.2.0")
  @callback get_invite(code :: String.t()) :: {:ok, Invite.t()} | {:error, term()}

  @doc """
    Deletes an invite.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/invite#get-invite).
  """
  Version.since("0.2.0")

  @callback delete_invite(invite_or_code :: String.t() | Invite.t()) ::
              {:ok, Invite.t()} | {:error, term()}

  @doc """
    Gets a user from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/user#get-user).
  """
  Version.since("0.2.0")

  @callback get_user(user :: User.id_resolvable()) :: {:ok, User.t()} | {:error, term()}

  @doc """
  Gets the current user from the api.

  For more information see [Discord Docs](https://discord.com/developers/docs/resources/user#get-current-user).
  """
  Version.since("0.2.1")
  @callback get_current_user() :: {:ok, User.t()} | {:error, term()}

  @typedoc """
    Used to modify the currently logged in `c:modify_current_user/1`.
  """
  Version.typesince("0.1.4")

  @type modify_current_user_data ::
          %{
            optional(:username) => String.t(),
            optional(:avatar) => Util.image()
          }
          | [{:username, String.t()} | {:avatar, Util.image() | nil}]

  @doc """
    Modifes the currently logged in user.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/user#modify-current-user).
  """
  Version.since("0.2.0")

  @callback modify_current_user(data :: Crux.Rest.modify_current_user_data()) ::
              {:ok, User.t()} | {:error, term()}

  @typedoc """
    Used to list the current user's guilds in `c:get_current_user_guild/1`.
  """
  Version.typesince("0.1.4")

  @type get_current_user_guild_data ::
          %{
            optional(:before) => Message.id_resolvable(),
            optional(:after) => Message.id_resolvable(),
            optional(:limit) => pos_integer()
          }
          | [
              {:before, Message.id_resolvable()}
              | {:after, Message.id_resolvable()}
              | {:limit, pos_integer()}
            ]

  @doc """
  Gets a list of partial `Crux.Structs.Guild`s the current user is a member of.

  For more informations see [Discord Docs](https://discord.com/developers/docs/resources/user#get-current-user-guilds).
  """

  Version.since("0.2.0")

  @callback get_current_user_guilds(data :: Crux.Rest.get_current_user_guild_data()) ::
              {:ok, %{required(Snowflake.t()) => Guild.t()}} | {:error, term()}

  @doc """
    Leaves a guild.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/user#leave-guild).
  """
  Version.since("0.2.0")
  @callback leave_guild(guild :: Guild.id_resolvable()) :: :ok | {:error, term()}

  @doc """
    Creates a new dm channel with a user.

    For more informations see [Discord Docs](https://discord.com/developers/docs/resources/user#create-dm).
  """
  Version.since("0.2.0")
  @callback create_dm(user :: User.id_resolvable()) :: {:ok, Channel.t()} | {:error, term()}

  @doc """
    Gets the gateway url from the api.

    For more informations see [Discord Docs](https://discord.com/developers/docs/topics/gateway#get-gateway).
  """
  Version.since("0.2.0")
  @callback gateway() :: {:ok, term()} | {:error, term()}

  @doc """
     Gets the gateway url along a recommended shards count from the api.

     For more informations see [Discord Docs](https://discord.com/developers/docs/topics/gateway#get-gateway-bot).
  """
  Version.since("0.2.0")
  @callback gateway_bot() :: {:ok, term()} | {:error, term()}

  @doc """
    Executes a request.
  """
  Version.since("0.2.0")
  @spec request(name :: atom(), request :: Request.t()) :: :ok | {:ok, term()} | {:error, term()}
  def request(name, request) do
    case Crux.Rest.Handler.queue(name, request) do
      # Empty resonse
      {:ok, %{status_code: 204}} ->
        :ok

      # A HTTP error occured
      {:ok, %HTTPoison.Response{status_code: code} = response}
      when code in 400..599 ->
        {:error, ApiError.exception(request, response)}

      # Everything ok
      {:ok, %{body: data}} ->
        {:ok, Request.transform(request, data)}

      # Some other error occured
      {:error, _other} = error ->
        error
    end
  end

  @doc """
    Executes a request, but raises on error.
  """
  Version.since("0.2.0")
  @spec request!(name :: atom(), request :: Request.t()) :: term() | no_return()
  def request!(name, request) do
    case request(name, request) do
      :ok -> :ok
      {:ok, data} -> data
      {:error, error} -> raise error
    end
  end

  @typedoc """
    Options used to start `Crux.Rest`.
  """
  Version.typesince("0.2.0")

  @type options ::
          %{
            required(:token) => String.t(),
            optional(:retry_limit) => non_neg_integer() | :infinity
          }
          | [{:token, String.t()} | {:retry_limit, non_neg_integer() | :infinity}]

  @doc """
    Starts a `Crux.Rest` process linked to the current process.

    Options are a tuple of a name atom and `t:options/0`.
  """
  @spec start_link({name :: atom(), options()}) :: Supervisor.on_start()
  defdelegate start_link(args), to: Handler.Supervisor

  @doc false
  Version.since("0.2.0")
  @spec child_spec({name :: atom(), args :: options()}) :: Supervisor.child_spec()
  def child_spec({name, _args} = arg) when is_atom(name) do
    %{
      id: __MODULE__,
      start: {Crux.Rest.Handler.Supervisor, :start_link, [arg]},
      type: :supervisor
    }
  end

  @doc false
  def apply_options(%{transform: transform} = request, %{transform: false} = opts)
      when not is_nil(transform) do
    apply_options(%{request | transform: nil}, opts)
  end

  def apply_options(request, _opts) do
    request
  end

  @spec __using__() :: term()
  defmacro __using__(opts \\ []) do
    quote location: :keep do
      @opts unquote(opts) |> Map.new()

      @behaviour Crux.Rest

      @name __MODULE__

      use Crux.Rest.Gen.Bang, :functions

      def start_link(arg) do
        Crux.Rest.start_link({@name, arg})
      end

      def child_spec(arg) do
        Crux.Rest.child_spec({@name, arg})
      end

      def request(request) do
        Crux.Rest.request(@name, request)
      end

      def request!(request) do
        Crux.Rest.request!(@name, request)
      end

      @deprecated "Use request/1 instead"
      defdelegate request(name, request), to: Crux.Rest
      @deprecated "Use request!/1 instead"
      defdelegate request!(name, request), to: Crux.Rest

      defoverridable request: 1, request!: 1, request: 2, request!: 2
    end
  end
end
