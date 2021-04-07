defmodule Crux.Rest do
  @moduledoc """
  Behaviour module specifying injected functions when `use`-ing this module within another module.

  Those functions then can be used to interact with Discord's REST API after starting the module, probably under a supervisor.

  #### Examples

  TODO: Write me!

  #### A few words on semver

  This behavior is not intended to be implemented by yourself.
  If you still decide to do so, keep in mind that with every
  minor version there might be new **non-optional** callbacks added.

  Discord might remove parameters or endpoints or decide
  to disallow certain behavior at any point.
  There is not much that can be done about this, semver or not.

  Relevant upstream documentation: [Discord Developer Documentation](https://discord.com/developers/docs/intro)
  """
  @moduledoc since: "0.1.0"

  defmacro __using__([]) do
    Crux.Rest.Impl.Injector.inject(__CALLER__)
  end

  defmacro __using__(_opts) do
    raise ArgumentError,
          "Crux.Rest does not accept any options when `use`-ing this module, provide them when starting it instead."
  end

  require Crux.Rest.Bangify

  alias Crux.Rest.Request

  alias Crux.Structs.{
    Application,
    AuditLog,
    Channel,
    Emoji,
    Guild,
    GuildPreview,
    Integration,
    Invite,
    Member,
    Message,
    Overwrite,
    Permissions,
    Role,
    Snowflake,
    Template,
    User,
    VoiceRegion,
    Webhook
  }

  ###
  # Conventions START
  ###

  # Callbacks are ordered in the same way as they appear in the upstream documentation.

  # Callback names are getting a prefix depending on the HTTP verb of the endpoint they use:
  # - GET         -> get_
  # - POST        -> create_
  # - PATCH / PUT -> modify_
  # - DELETE      -> delete_

  # Required path params are separate parameters.
  # Other params an options enumerable. (With exceptions)
  # Options are always suffixed with "_options".

  ###
  # Conventions END
  ###

  @typedoc """
  An api results that does not return any data.

  I.e. a "204 No Content" HTTP response code.
  """
  @typedoc since: "0.3.0"
  @type api_result() :: :ok | {:error, Crux.Rest.ApiError.t()}

  @typedoc """
  An api result that returns data of type `type`.
  """
  @typedoc since: "0.3.0"
  @type api_result(type) :: {:ok, type} | {:error, Crux.Rest.ApiError.t()}

  @typedoc """
  An api results that does not return any data or raises on error.

  I.e. a "204 No Content" HTTP response code.
  """
  @typedoc since: "0.3.0"
  @type api_result!() :: :ok | no_return()

  @typedoc """
  An api result that returns data of type `type` or raises on error.
  """
  @typedoc since: "0.3.0"
  @type api_result!(type) :: type | no_return()

  @typedoc """
  A map of `type` keyed under their ids.
  """
  @typedoc since: "0.3.0"
  @type snowflake_map(type) :: %{required(Snowflake.t()) => type}

  # Automatically generate corresponding bangified callbacks using bangified return types.
  Crux.Rest.Bangify.bangify do
    @doc """
    Executes the given request.
    """
    @doc since: "0.3.0"
    @callback request(request :: Request.t()) :: api_result() | api_result(term)

    ###
    # Slash Commands START
    ###

    @typedoc """
    An application (or slash) command, received as response from:
    - `c:get_global_application_commands/1`
    - `c:create_global_application_command/2`
    - `c:modify_global_application_command/3`
    - `c:get_guild_application_commands/2`
    - `c:create_guild_application_command/3`
    - `c:modify_guild_application_command/4`

    ## Notes
    - `name` must be [3,32] characters long.
    - `description` must be [1,100] characters long.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#applicationcommand).
    """
    @typedoc since: "0.3.0"
    @type application_command :: %{
            required(:id) => Snowflake.t(),
            required(:application_id) => Snowflake.t(),
            required(:name) => String.t(),
            required(:description) => String.t(),
            optional(:options) => [application_command_option()]
          }

    @typedoc """
    Possible options for an application command.

    Notes
    * `name` must be [1,32] characters long
    * `description` must be [1,100] characters long
    * Only one required option may be `default`
    * `required` may not be after a none required option
    * `choices` are only valid if the type is either integer or string.
    * `options` is only valid if the type is either `sub_command` or `sub_command_group`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoption).
    """
    @typedoc since: "0.3.0"
    @type application_command_option :: %{
            required(:type) => application_command_option_type(),
            required(:name) => String.t(),
            required(:description) => String.t(),
            optional(:default) => boolean(),
            optional(:required) => boolean(),
            optional(:choices) => [application_command_option_choice()],
            optional(:options) => [application_command_option()]
          }

    @typedoc """
    All available command option types:
    * `sub_command`: 1
    * `sub_command_group`: 2
    * `string`: 3
    * `integer`: 4
    * `boolean`: 5
    * `user`: 6
    * `channel`: 7
    * `role`: 8

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoptiontype).
    """
    @typedoc since: "0.3.0"
    @type application_command_option_type :: 1..8

    @typedoc """
    Choices for a string or integer type.
    Name must be [1,100] chars long.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoptionchoice).
    """
    @typedoc since: "0.3.0"
    @type application_command_option_choice :: %{
            name: String.t(),
            value: String.t() | integer()
          }

    @typedoc """
    The same as `t:application_command/0`, but `id` is optional and without `application_id`.

    This can also be a module that `use`s `Crux.Interaction.SlashCommand`.
    """
    @typedoc since: "0.3.0"
    @type application_command_data ::
            %{
              optional(:id) => Snowflake.t(),
              required(:name) => String.t(),
              required(:description) => String.t(),
              optional(:options) => [application_command_option()]
            }
            | module()

    @doc """
    Get a globally registered command for your application.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#get-global-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback get_global_application_command(
                application :: Application.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command()
              ) :: api_result(snowflake_map(application_command()))

    @doc """
    Get all globally registered commands for your application.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#get-global-application-commands).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback get_global_application_commands(application :: Snowflake.resolvable()) ::
                api_result(snowflake_map(application_command()))

    @doc """
    Register a command globally, if a name with the specified name already exists, this will overwrite it.

    > New global commands will take up to 1 hour until they are available in all guilds.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#create-global-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_global_application_command(
                application :: Application.id_resolvable(),
                command_data :: application_command_data()
              ) :: api_result(application_command())

    @doc """
    Replace all globally registered commands.
    If a command in the list did not exist, it will be created.
    If a command in the list already existed, it will be overwritten.
    If an already existing command is not in this list, it will be deleted.

    > New global commands will take up to 1 hour until they are available in all guilds.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-global-application-commands).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_global_application_commands(
                application :: Application.id_resolvable(),
                commands_data :: [application_command_data()]
              ) :: api_result(application_command())

    @doc """
    Modify a globally registered command.

    > Updates will take up to 1 hour until they are available in all guilds.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#edit-global-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback modify_global_application_command(
                application :: Application.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command(),
                command_data :: application_command_data()
              ) :: api_result(application_command())

    @doc """
    Delete a globally registered command.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#delete-global-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback delete_global_application_command(
                application :: Application.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command()
              ) :: api_result()

    @doc """
    Get a command that is registered in a guild. (This is excluding global commands.)

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#get-guild-application-commands).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback get_guild_application_command(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command()
              ) :: api_result(snowflake_map(application_command()))

    @doc """
    Get all commands that are registered in a guild. (This is excluding global commands.)

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#get-guild-application-commands).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback get_guild_application_commands(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable()
              ) :: api_result(snowflake_map(application_command()))

    @doc """
    Register a command in a specific guild, if a name with the specified name already exists, this will overwrite it.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#create-guild-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_guild_application_command(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable(),
                command_data :: application_command_data()
              ) :: api_result(application_command())

    @doc """
    Replace all commands registered in a guild.
    If a command in the list did not exist, it will be created.
    If a command in the list already existed, it will be overwritten.
    If an already existing command is not in this list, it will be deleted.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-guild-application-commands).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_guild_application_commands(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable(),
                commands_data :: [application_command_data()]
              ) :: api_result(application_command())


    @doc """
    Modify a command that was registered in a specific guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#edit-guild-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback modify_guild_application_command(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command(),
                command_data :: application_command_data()
              ) :: api_result(application_command())

    @doc """
    Delete a command that was registered in a specific guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#delete-guild-application-command).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback delete_guild_application_command(
                application :: Application.id_resolvable(),
                guild :: Guild.id_resolvable(),
                command_id :: Snowflake.resolvable() | application_command()
              ) :: api_result()

    @typedoc """
    """
    @typedoc since: "0.3.0"
    @type interaction_response ::
            %{type: 1}
            | %{
                required(:type) => 2..5,
                optional(:data) => %{
                  optional(:tts) => boolean(),
                  optional(:content) => String.t(),
                  optional(:embeds) => [embed_options()],
                  optional(:allowed_mentions) => allowed_mentions_options()
                }
              }

    @doc """
    Create a response to an interaction from the gateway. (HTTP should send it as response to the webhook).

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#create-interaction-response).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_interaction_response(
                interaction_id :: Snowflake.resolvable(),
                interaction_token :: String.t(),
                opts :: interaction_response()
              ) :: api_result(map())
    

    @doc """
    Get the initially sent response to an interaction.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#get-original-interaction-response).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback get_original_interaction_response(
                application :: Application.id_resolvable(),
                interaction_token :: String.t(),
                opts :: modify_webhook_message_options()
              ) :: api_result(Message.t())

    @doc """
    Modify the initially sent response to an interaction.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#edit-original-interaction-response).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback modify_original_interaction_response(
                application :: Application.id_resolvable(),
                interaction_token :: String.t(),
                opts :: modify_webhook_message_options()
              ) :: api_result(Message.t())

    @doc """
    Delete the initially sent response to an interaction.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#delete-original-interaction-response).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback delete_original_interaction_response(
                application :: Application.id_resolvable(),
                interaction_token :: String.t()
              ) :: api_result()

    @doc """
    Create a followup message for an interaction.

    > This only supports Discord style options.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#create-followup-message).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback create_followup_message(
                application :: Application.id_resolvable(),
                interaction_token :: String.t(),
                opts :: create_webhook_message_options()
              ) :: api_result(Message.t())

    @doc """
    Edit a followup message for an interaction.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#edit-followup-message).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback modify_followup_message(
                application :: Application.id_resolvable(),
                interaction_token :: String.t(),
                message :: Message.id_resolvable(),
                opts :: modify_webhook_message_options()
              ) :: api_result(Message.t())

    @doc """
    Delete a followup message for an interaction.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/slash-commands#delete-followup-message).
    """
    @doc since: "0.3.0"
    @doc section: :slash_commands
    @callback delete_followup_message(
                application :: Application.id_resolvable(),
                interaction_token :: String.t(),
                message :: Message.id_resolvable()
              ) :: api_result()

    ###
    # Slash Commands END
    ###

    ###
    # Audit Log START
    ###

    @typedoc """
    Used to filter or limit audit log entries obtained using `c:get_audit_log/2`.
    Note that the `:user_id` refers to the `executor` and **not** the `target`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log-query-string-parameters).
    """
    @typedoc since: "0.1.7"
    @type audit_log_options ::
            %{
              optional(:user_id) => User.id_resolvable(),
              optional(:action_type) => pos_integer(),
              optional(:before) => Snowflake.resolvable(),
              optional(:limit) => pos_integer()
            }
            | [
                {:user_id, User.id_resolvable()}
                | {:action_type, pos_integer()}
                | {:before, Snowflake.resolvable()}
                | {:limit, pos_integer()}
              ]

    @doc """
    Get the audit log for the guild.
    This operation requires `view_audit_log` permissions.

    For more informations see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_audit_log(
                guild :: Guild.id_resolvable(),
                opts :: audit_log_options()
              ) :: api_result(AuditLog.t())

    ###
    # Audit Log END
    ###

    ###
    # Channel START
    ###

    @doc """
    Get a channel by id.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel).
    """
    @doc since: "0.2.0"
    @doc section: :channel
    @callback get_channel(channel :: Channel.id_resolvable()) :: api_result(Channel.t())

    @typedoc """
    Used to create or replace overwrites when creating or editing a channel or a single overwrite.

    If you specify an `id` as `:id`, `:type` is required.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#overwrite-object).
    """
    @typedoc since: "0.3.0"
    @type overwrite_options ::
            %{
              required(:id) => User.id_resolvable() | Role.id_resolvable(),
              optional(:allow) => Permissions.resolvable(),
              optional(:deny) => Permissions.resolvable(),
              optional(:type) => member_or_role :: String.t()
            }
            | [
                {:id, User.id_resolvable() | Role.id_resolvable()}
                | {:allow, Permissions.resolvable()}
                | {:deny, Permissions.resolvable()}
                | {:type, member_or_role :: String.t()}
              ]
            | Overwrite.t()

    @typedoc """
    Used to create or edit a channel using respectively `c:create_channel/2` or `c:modify_channel/2`.

    ## Notes
    - `:name` - has to be [2, 100] characters long.
    - `:type` - when editing, may only be changed from and to `text` and `news`.
    - `:topic` - has to be [0, 1024] characters long.
    - `:rate_limit_per_user` - has to be [0, 21_600], 0 refers to no limit.
      Amount of seconds a user has to wait before sending another message.
      Bots and users with `manage_messages` or `manage_channels` are unaffacted.
    - `:bitrate` - in bits and has allowed values [8_000, 96_000] (up to 128_000 for VIP servers)
    - `:user_limit` - has to be [0, 99]. 0 refers to no limit
      Amount of users that can connect to a voice channel at the same time.
      Users with the permission `move_members` are unaffacted.

    For more information see the Discord Developer Documentation: [create](https://discord.com/developers/docs/resources/guild#create-guild-channel-json-params) or [edit](https://discord.com/developers/docs/resources/channel#modify-channel-json-params).
    """
    @typedoc since: "0.3.0"
    @type channel_options ::
            %{
              optional(:name) => String.t(),
              optional(:type) => Channel.type(),
              optional(:position) => integer(),
              optional(:topic) => String.t() | nil,
              optional(:nsfw) => boolean(),
              optional(:rate_limit_per_user) => 0..21_600,
              optional(:bitrate) => 8_000..96_000 | 8_000..128_000,
              optional(:user_limit) => 0..99,
              optional(:permission_overwrites) => [overwrite_options()],
              optional(:parent_id) => Channel.id_resolvable(),
              optional(:rtc_region) => String.t() | nil,
              optional(:reason) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:type, Channel.type()}
                | {:position, integer()}
                | {:topic, String.t() | nil}
                | {:nsfw, boolean()}
                | {:rate_limit_per_user, 0..21_600}
                | {:bitrate, 8_000..96_000 | 8_000..128_000}
                | {:user_limit, 0..99}
                | {:permission_overwrites, [overwrite_options()]}
                | {:parent_id, Channel.id_resolvable()}
                | {:rtc_region, String.t() | nil}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Edit a channel.
    This operation requires the `manage_channels` permissions.
    Additionally editing permission overwrites requires the `manage_roles` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#modify-channel).
    """
    @doc since: "0.2.0"
    @doc section: :channel
    @callback modify_channel(
                channel :: Channel.id_resolvable(),
                opts :: channel_options()
              ) :: api_result()

    @doc """
    Delete a guild channel, or close a DM channel.
    Requires the `manage_channels` permission for a guild channel.

    ## Notes
    - You may not delete a public guild's `rules_channel` and `public_updates_channel`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#deleteclose-channel).
    """
    @doc since: "0.2.0"
    @doc section: :channel
    @callback delete_channel(
                channel :: Channel.id_resolvable(),
                reason :: String.t()
              ) :: api_result(Channel.t())

    @typedoc """
    Used to filter or limit messages obtained by using `c:get_messages/2`.
    Note that the non-limit options are mutually exclusive.

    ## Notes
    - `:limit` is defaulting to `50` and is capped at `100`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel-messages-query-string-params).
    """
    @typedoc since: "0.3.0"
    @type get_messages_options ::
            %{
              optional(:around) => Message.id_resolvable(),
              optional(:before) => Message.id_resolvable(),
              optional(:after) => Message.id_resolvable(),
              optional(:limit) => 1..100
            }
            | [
                {:around, Message.id_resolvable()}
                | {:before, Message.id_resolvable()}
                | {:after, Message.id_resolvable()}
                | {:limit, 1..100}
              ]

    @doc """
    Get messages from a channel.
    If a guild channel, this operation requires the `view_channel` and `read_message_history` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel-messages).
    """
    @doc since: "0.3.0"
    @doc section: :message
    @callback get_messages(
                channel :: Channel.id_resolvable(),
                opts :: get_messages_options()
              ) :: api_result(snowflake_map(Message.t()))

    @doc """
    Get a message from a channel.
    If a guild channel, this operation requires the `view_channel` and `read_message_history` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    @callback get_message(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable()
              ) :: api_result(Messaage.t())

    @doc """
    Get a message from a channel.
    If a guild channel, this operation requires the `view_channel` and `read_message_history` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    # Shortcut
    @callback get_message(message :: Message.t()) :: api_result(Message.t())

    @typedoc ~S"""
    Used to send embed(s) when using `c:create_message/2` or `c:create_webhook_message/2,3`.

    Note that this must always be a map, unlike other options.

    ## Limitations
    - `title` 256 characters
    - `description` 2048 characters
    - `fields` 25 fields
    - `fields.name` 256 characters
    - `fields.value` 1024 characters
    - `footer.text` 2048 characters
    - `author.name` 256 characters
    - All fields with a character limitation combined may not exceed 6000 characters  in total
    For more information about embed limits, see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#embed-limits).

    ## Files
    It's possible to use images attached to a message in embeds using the attachment scheme:
    `attachment://#{filename}.#{fileextension}`
    Note that "fileextension" must be a proper image extension.
    For more information about attachments within embeds, see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-message-using-attachments-within-embeds).

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#embed-object).
    """
    @typedoc since: "0.3.0"
    @type embed_options :: %{
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

    @typedoc """
    Used to specify what (kind of) mentions are allowed to actually notify users.

    ## Notes
    - When specifying `:roles` or `:users` in `:parse`, also specifying `:roles` or `:users` at top-level will raise a validation error on Discord's end.
    Note that "falsy" values will not cause such a validation error. (Discord defines "falsy" as `[]` or `nil` here)
    - `:allowed_mentions` acts as a mere whitelist, allowed mentions not included in the content will simply be ignored.
    - Mentions included in the content but not in the whitelist will render as regular mentions, but not notify users.

    You can find a few examples in the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mentions-reference).

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#allowed-mentions-object).
    """
    @typedoc since: "0.3.0"
    @type allowed_mentions_options ::
            %{
              optional(:parse) => [:roles | :users | :everyone | String.t()],
              optional(:roles) => [Role.id_resolvable()],
              optional(:users) => [User.id_resolvable()],
              optional(:replied_user) => boolean()
            }
            | [
                {:parse, [:roles | :users | :everyone | String.t()]}
                | {:roles, [Role.id_resolvable()]}
                | {:users, [User.id_resolvable()]}
                | {:replied_user, boolean()}
              ]

    @typedoc """
    Used to attach files when using `c:create_message/2` or `c:create_webhook_message/2,3`.

    ## Examples

    Example for a simple text file:
    `{<<104, 101, 108, 108, 111>>, "hello.txt"}` equivalent to `{"hello", "hello.txt"}`

    Example for an image file:
    `{File.read!("/path/to/image.png"), "image.png"}`
    """
    @typedoc since: "0.3.0"
    @type file_options :: {data :: binary(), filename :: String.t()}

    @typedoc """
    Used to reply to a previously send message using `c:create_message/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#message-object-message-reference-structure).
    """
    @typedoc since: "0.3.0"
    @type message_reference ::
            %{
              optional(:message_id) => Message.id_resolvable(),
              optional(:channel_id) => Channel.id_resolvable(),
              optional(:guild_id) => Guild.id_resolvable()
            }
            | [
                {:message_id, Message.id_resolvable()}
                | {:channel_id, Message.id_resolvable()}
                | {:guild_id, Message.id_resolvable()}
              ]

    @typedoc """
    Used to post messages to a channel by using `c:create_message/2,3`.

    The maximum request size when sending a message is 8MB.

    ## Permissions
    - `send_tts_messages` if using `tts: true` (silently fails if no permission)
    - `embed_links` if using `:embed`
    - `embed_links` when intending to embed links in `content` (silently fails if no permission)
    - `attach_files` if using `:files`
    - `mention_everyone` if intending to mention `@everyone`, `@here`, or roles that are not marked as mentionable (silently fails if no permission)
    - `use_external_emojis` if using external emoji in the message content (silently fails if no permission)
    - `view_message_history` if replying to a message using `:message_reference`

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-message-params).
    """
    @typedoc since: "0.3.0"
    @type create_message_options ::
            %{
              optional(:content) => String.t(),
              optional(:nonce) => String.t() | integer(),
              optional(:tts) => boolean(),
              optional(:files) => [file_options()],
              optional(:embed) => Embed.t() | embed_options(),
              optional(:allowed_mentions) => allowed_mentions_options(),
              optional(:message_reference) => message_reference()
            }
            | [
                {:content, String.t()}
                | {:nonce, String.t() | integer()}
                | {:tts, boolean()}
                | {:files, [file_options()]}
                | {:embed, Embed.t() | embed_options()}
                | {:allowed_mentions, allowed_mentions_options()}
                | {:message_reference, message_reference()}
              ]

    @doc """
    Post a message to a channel.
    If a guild channel, this operation requires the `view_channel` and `send_messages` permissions
    and additional permissions depending on the options.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    @callback create_message(
                channel :: Channel.id_resolvable(),
                opts :: create_message_options()
              ) :: api_result(Message.t())

    @doc """
    Crosspost a message sent in a news channel to all following channels.
    This operation required `send_messages` permission if the message was sent by the current user, otherwise it _also_ requires `manage_messages`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#crosspost-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    @callback create_message_crosspost(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable()
              ) :: api_result(Message.t())

    @doc """
    Crosspost a message sent in a news channel to all following channels.
    This operation required `send_messages` permission if the message was sent by the current user, otherwise it _also_ requires `manage_messages`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#crosspost-message).
    """
    # Shortcut
    @doc since: "0.3.0"
    @doc section: :message
    @callback create_message_crosspost(message :: Message.t()) :: api_result(Message.t())

    @doc """
    Adds the current user to a reaction of a message, or create a reaction of a message.
    If a guild channel, this operation requires the `view_channel`, `read_message_history` permissions.
    Additionally, if nobody else has reacted to the message already `add_reactions` is also required.
    If the to be added emoji is from a different guild, also the `use_external_emojis` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-reaction).
    """
    @doc since: "0.2.0"
    @doc section: :reaction
    @callback create_reaction(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                emoji :: Emoji.identifier_resolvable()
              ) :: api_result()

    @doc """
    Adds the current user to a reaction of a message, or create a reaction of a message.
    If a guild channel, this operation requires the `view_channel`, `read_message_history` permissions.
    Additionally, if nobody else has reacted to the message already `add_reactions` is also required.
    If the to be added emoji is from a different guild, also the `use_external_emojis` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-reaction).
    """
    @doc since: "0.2.0"
    @doc section: :reaction
    # Shortcut
    @callback create_reaction(
                message :: Message.t(),
                emoji :: Emoji.identifier_resolvable()
              ) :: api_result()

    @doc """
    Delete a user from a reaction, if its last user, the reaction as whole.
    If deleting another user's reaction, this operation requires the `manage_messages` permissions.

    To delete the reaction from the current user use `"@me"` as user.

    For more information see the Discord Developer Documentation: [`"@me"`](https://discord.com/developers/docs/resources/channel#delete-own-reaction) and [user](https://discord.com/developers/docs/resources/channel#delete-user-reaction).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    @callback delete_user_reaction(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                emoji :: Emoji.identifier_resolvable(),
                user :: User.id_resolvable() | String.t()
              ) :: api_result()

    @doc """
    Delete a user from a reaction, if its last user, the reaction as whole.
    If deleting another user's reaction, this operation requires the `manage_messages` permissions.

    To delete the reaction from the current user use `"@me"` as user.

    For more information see the Discord Developer Documentation: [`"@me"`](https://discord.com/developers/docs/resources/channel#delete-own-reaction) and [user](https://discord.com/developers/docs/resources/channel#delete-user-reaction).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    # Shortcut
    @callback delete_user_reaction(
                message :: Message.t(),
                emoji :: Emoji.identifier_resolvable(),
                user :: User.id_resolvable() | String.t()
              ) :: api_result()

    @typedoc """
    Used to obtain users that reacted with an emoji to a message using `c:get_reactions/3,4`.

    ## Notes
    - `:limit` is defaulting to `25` and is capped at `100`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-reactions-query-string-params).
    """
    @typedoc since: "0.3.0"
    @type get_reactions_options ::
            %{
              optional(:after) => User.id_resolvable(),
              optional(:limit) => 1..100
            }
            | [
                {:before, User.id_resolvable()}
                | {:before, User.id_resolvable()}
                | {:limit, 1..100}
              ]

    @doc """
    Get users that reacted with an emoji.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-reactions)
    """
    @doc since: "0.2.0"
    @doc section: :reaction
    @callback get_reactions(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                emoji :: Emoji.identifier_resolvable(),
                opts :: get_reactions_options()
              ) :: api_result(snowflake_map(User.t()))

    @doc """
    Get users that reacted with an emoji.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-reactions)
    """
    @doc since: "0.2.0"
    @doc section: :reaction
    # Shortcut
    @callback get_reactions(
                message :: Message.t(),
                emoji :: Emoji.identifier_resolvable(),
                opts :: get_reactions_options()
              ) :: api_result(snowflake_map(User.t()))

    @doc """
    Delete all reaction on a message.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-all-reactions).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    @callback delete_all_reactions(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable()
              ) :: api_result()

    @doc """
    Delete all reactions on a message.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-all-reactions).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    # Shortcut
    @callback delete_all_reactions(message :: Message.t()) :: api_result()

    @doc """
    Delete all reactions for a given emoji on a message.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    @callback delete_all_reactions_for_emoji(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                emoji :: Emoji.identifier_resolvable()
              ) :: api_result()

    @doc """
    Delete all reactions for a given emoji on a message.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :reaction
    # Shortcut
    @callback delete_all_reactions_for_emoji(
                message :: Message.t(),
                emoji :: Emoji.identifier_resolvable()
              ) :: api_result()

    @typedoc """
    Used to edit a previously sent message using `c:modify_message:2,3`.
    If editing another user's message only `flags` may be used.

    ## Notes
    - `:content` must be [0, 2000] characters in length.
    """
    @typedoc since: "0.3.0"
    @type modify_message_options :: %{
            optional(:content) => String.t(),
            optional(:embed) => Embed.t() | embed_options(),
            optional(:flags) => integer(),
            optional(:allowed_mentions) => allowed_mentions_options()
          }

    @doc """
    Edit a previously sent message.
    If editing another user's message, this operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#edit-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    @callback modify_message(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                data :: modify_message_options()
              ) :: api_result(Message.t())

    @doc """
    Edit a previously sent message.
    If editing another user's message, this operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#edit-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    # Shortcut
    @callback modify_message(
                message :: Message.t(),
                data :: modify_message_options()
              ) :: api_result(Message.t())

    @doc """
    Delete a message.
    If deleting a message of another user, this operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    @callback delete_message(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable()
              ) :: api_result()

    @doc """
    Delete a message.
    If deleting a message of another user, this operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    # Shortcut
    @callback delete_message(message :: Message.t()) :: api_result()

    @doc """
    Delete multiple messages in one single request.
    This operation requires the `manage_messages` permission.

    ## Notes
    - There must be [2, 100] messages specified.
    - There must not be any duplicated messages.
    - There must not be any messages older than 14 days.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#bulk-delete-messages).
    """
    @doc since: "0.3.0"
    @doc section: :message
    @callback delete_messages(
                channel :: Channel.id_resolvable(),
                messages :: [Message.id_resolvable()]
              ) :: api_result()

    @doc """
    Edit (or create) the overwrite of a channel for a role or user.
    This operation requires the `manage_roles` permission.

    ## See Also
    - To replace all existing overwrites use `c:modify_channel/2` instead.
    - To delete an overwrite completely use `c:delete_channel_overwrite/3` instead.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#edit-channel-permissions).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback modify_channel_overwrite(
                channel :: Channel.id_resolvable(),
                overwrite_data :: overwrite_options(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Get all invites of a channel.
    This operation requires the `manage_channels` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-channel-invites).
    """
    @doc since: "0.2.0"
    @doc section: :invite
    @callback get_channel_invites(channel :: Channel.id_resolvable()) ::
                api_result(%{required(code :: String.t()) => Invite.t()})

    @typedoc """
    Used to create invites using `c:create_invite/2`.

    ## Notes
    - `:max_age` is in seconds, 0 refers for no max age.
    - `:max_uses` 0 for unlimited uses.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-channel-invite-json-params).
    """
    @typedoc since: "0.3.0"
    @type create_invite_options ::
            %{
              optional(:max_age) => 0..86_400,
              optional(:max_uses) => 0..100,
              optional(:temporary) => boolean(),
              optional(:unique) => boolean(),
              optional(:target_user) => User.id_resolvable(),
              optional(:target_user_type) => integer(),
              optional(:reason) => String.t() | nil
            }
            | [
                {:max_age, 0..86_400}
                | {:max_uses, 0..100}
                | {:temporary, boolean()}
                | {:unique, boolean()}
                | {:target_user, User.id_resolvable()}
                | {:target_user_type, integer()}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Create an invite for a channel.
    This operation requires the `create_instant_invite` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#create-channel-invite).
    """
    @doc since: "0.3.0"
    @doc section: :invite
    @callback create_invite(
                channel :: Channel.id_resolvable(),
                options :: create_invite_options()
              ) :: api_result(Invite.t())

    @doc """
    Delete a channel ovewrite.
    This operation requires the `manage_roles` permission.

    ## See Also
    - To replace all existing overwrites use `c:modify_channel/2` instead.
    - To create or edit overwrites use `c:modify_channel_overwrite/3` instead.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-channel-permission).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback delete_channel_overwrite(
                channel :: Channel.id_resolvable(),
                overwrite :: User.id_resolvable() | Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Creates webhook that sends crossposted messages from the news channel to the target channel.
    This operation requires the `manage_webhooks` permission in the target channel.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#follow-news-channel).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback create_news_channel_webhook(
                news_channel :: Channel.id_resolvable(),
                webhook_channel :: Channel.id_resolvable()
              ) :: api_result()

    @doc """
    Create a typing indicator in a channel.

    Bots should generally not use this endpoint if the operation is not expected to take some time.
    A typing indicator is valid for ~9 seconds or until a message is sent.

    This operation requires the same permissions as sending a message.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#trigger-typing-indicator).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback create_typing_indicator(channel :: Channel.id_resolvable()) :: api_result()

    @doc """
    Get all pinned messages in a channel.
    This operation requires the `view_channel` and `read_message_history` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#get-pinned-messages).
    """
    @doc since: "0.2.0"
    @doc section: :message
    @callback get_pinned_messages(channel :: Channel.id_resolvable()) ::
                api_result(snowflake_map(Message.t()))

    @doc """
    Pin a message in a channel.
    This operation requires the `manage_messages` permissions.

    The maxmimum amount of pinned messages per channel is 50.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#add-pinned-channel-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    @callback create_pinned_message(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Pin a message in a channel.
    This operation requires the `manage_messages` permission.

    The maxmimum amount of pinned messages per channel is 50.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#add-pinned-channel-message).
    """
    @doc since: "0.3.0"
    @doc section: :message
    # Shortcut
    @callback create_pinned_message(
                message :: Message.t(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Unpin a message in a channel.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-pinned-channel-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    @callback delete_pinned_message(
                channel :: Channel.id_resolvable(),
                message :: Message.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Unpin a message in a channel.
    This operation requires the `manage_messages` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#delete-pinned-channel-message).
    """
    @doc since: "0.2.0"
    @doc section: :message
    # Shortcut
    @callback delete_pinned_message(
                message :: Message.t(),
                reason :: String.t() | nil
              ) :: api_result()

    # No create_group_dm_recipient

    # No delete_group_dm_recipient

    ###
    # Channel END
    ###

    ###
    # Emoji START
    ###

    @doc """
    Get all emoji in a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/emoji#list-guild-emojis).
    """
    @doc since: "0.3.0"
    @doc section: :emoji
    @callback get_emojis(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(Emoji.t()))

    @doc """
    Get an emoji from a guild.

    ## Notes
    - `:user` is only present if the `manage_emojis` permission is set for the current user.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/emoji#get-guild-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :emoji
    @callback get_emoji(
                guild :: Guild.id_resolvable(),
                emoji :: Emoji.id_resolvable()
              ) :: api_result(Emoji.t())

    # TODO: Uncomment after guild_id was added to Crux.Structs.Emoji
    # @doc since: "0.3.0"
    # Shortcut
    # @callback get_emoji(emoji :: Emoji.t()) :: api_result(Emoji.t())

    @typedoc """
    Used to specify an image in various functions:
    - `c:create_emoji/2`
    - `c:modify_guild/2`
    - `c:modify_current_user/1`
    - `c:create_webhook/2`
    - `c:modify_webhook/2`

    For message attachments, see `t:file_options/0`.

    This must either be a base64 encoded [Data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs).
    Discord accepts the following content types:
    - `image/jpeg`
    - `image/png`
    - `image/gif`
    Example: `data:image/jpeg;base64,BASE64_ENCODED_JPEG_IMAGE_DATA`

    Or a tuple of `{extension, data}`.
    Example: `{"jpeg", JPEG_IMAGE_BINARY}`

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/reference#image-data).
    """
    @typedoc since: "0.3.0"
    @type image_options :: String.t() | {extension :: String.t(), data :: binary()}

    @typedoc """
    Used to create an emoji using `c:create_emoji/2`.
    """
    @typedoc since: "0.3.0"
    @type create_emoji_options ::
            %{
              required(:name) => String.t(),
              required(:image) => image_options(),
              optional(:roles) => [Role.id_resolvable()],
              optional(:reason) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:image, image_options()}
                | {:roles, [Role.id_resolvable()]}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Create an emoji in a guild.
    This operation requires the `manage_emojis` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/emoji#create-guild-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :emoji
    @callback create_emoji(
                guild :: Guild.id_resolvable(),
                data :: create_emoji_options()
              ) :: api_result(Emoji.t())

    @typedoc """
    Used to edit an emoji using `c:modify_emoji/3`.
    """
    @typedoc since: "0.3.0"
    @type modify_emoji_options ::
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
    Edit an emoji.
    This operation requires the `manage_emojis` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/emoji#modify-guild-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :emoji
    @callback modify_emoji(
                guild :: Guild.id_resolvable(),
                emoji :: Emoji.id_resolvable(),
                data :: modify_emoji_options()
              ) :: api_result(Emoji.t())

    # TODO: Uncomment after guild_id was added to Crux.Structs.Emoji
    # @doc since: "0.3.0"
    # Shortcut
    # @callback modify_emoji(
    #             emoji :: Emoji.t(),
    #             data :: modify_emoji_options()
    #           ) :: api_result(Emoji.t())

    @doc """
    Delete an emoji.
    This operation requires the `manage_emojis` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/emoji#delete-guild-emoji).
    """
    @doc since: "0.3.0"
    @doc section: :emoji
    @callback delete_emoji(
                guild :: Guild.id_resolvable(),
                emoji :: Emoji.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    # TODO: Uncomment after guild_id was added to Crux.Structs.Emoji
    # @doc since: "0.3.0"
    # Shortcut
    # @callback delete_emoji(emoji :: Emoji.t(), reason :: String.t() | nil) :: api_result()

    ###
    # Emoji END
    ###

    ###
    # Guild START
    ###

    @typedoc """
    Used to create a guild by using `c:create_guild/1`.

    **These are converted to a map, json encoded, and passed to Discord as-is.**

    Please refer to the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild) for options and how they work.
    """
    # That link is correct, there is a relevant warning above the parameters table for whatever reason. ^
    @typedoc since: "0.3.0"
    @type create_guild_options :: map() | list()

    @doc """
    Create a guild.
    This operation may only be used by bots in less than 10 guilds. (Ownership is irrelevant.)

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild).
    """
    @doc since: "0.2.0"
    @doc section: :guild
    @callback create_guild(data :: create_guild_options()) :: api_result(Guild.t())

    @doc """
    Get a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild).
    """
    @doc since: "0.2.0"
    @doc section: :guild
    @callback get_guild(guild :: Guild.id_resolvable()) :: api_result(Guild.t())

    @doc """
    Get a guild preview.
    This operation is only available for public guilds.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-preview).
    """
    @doc sinc: "0.3.0"
    @doc section: :guild
    @callback get_guild_preview(guild :: Guild.id_resolvable()) :: api_result(GuildPreview.t())

    @typedoc """
    Used to edit a guild by using `c:modify_guild/2`.

    ## Notes
    - `:name` must be [2, 100] characters long.
    - `:region` must be the id of one available guild region, you can fetch all applicable regions via `c:get_voice_regions/1`.
    - `:afk_timeout` is in seconds and must be one of (60, 300, 900, 1800, 3600).
    - `:preferred_locale` must be one of ("cs", "vi", "tr", "ko", "pl", "nl", "de", "ru", "ro", "en-GB", "es-ES", "hu", "uk", "zh-CN", "zh-TW", "el", "ja", "th", "pt-BR", "no", "fi", "lt", "hr", "fr", "da", "bg", "en-US", "sv-SE", "it").

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-json-params).
    """
    @typedoc since: "0.3.0"
    @type modify_guild_options ::
            %{
              optional(:name) => String.t(),
              optional(:region) => String.t(),
              optional(:verification_level) => 0..4,
              optional(:default_message_notifications) => 0..1,
              optional(:explicit_content_filter) => 0..2,
              optional(:afk_channel_id) => Channel.id_resolvable(),
              optional(:afk_timeout) => 60 | 300 | 900 | 1800 | 3600,
              optional(:icon) => image_options() | nil,
              optional(:owner_id) => User.id_resolvable(),
              optional(:splash) => image_options() | nil,
              optional(:discovery_splash) => image_options() | nil,
              optional(:banner) => image_options() | nil,
              optional(:system_channel_id) => Channel.id_resolvable() | nil,
              optional(:rules_channel_id) => Channel.id_resolvable(),
              optional(:public_update_channel_id) => Channel.id_resolvable(),
              optional(:preferred_locale) => String.t(),
              optional(:features) => [String.t()],
              optional(:description) => String.t() | nil,
              optional(:reason) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:region, String.t()}
                | {:verification_level, 0..4}
                | {:default_message_notifications, 0..1}
                | {:explicit_content_filter, 0..2}
                | {:afk_channel_id, Channel.id_resolvable()}
                | {:afk_timeout, 60 | 300 | 900 | 1800 | 3600}
                | {:icon, image_options() | nil}
                | {:owner_id, User.id_resolvable()}
                | {:splash, image_options() | nil}
                | {:discovery_splash, image_options() | nil}
                | {:banner, image_options() | nil}
                | {:system_channel_id, Channel.id_resolvable()}
                | {:rules_channel_id, Channel.id_resolvable()}
                | {:public_update_channel_id, Channel.id_resolvable()}
                | {:preferred_locale, String.t()}
                | {:features, [String.t()]}
                | {:description, String.t() | nil}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Edit a guild.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild).
    """
    @doc since: "0.2.0"
    @doc section: :guild
    @callback modify_guild(
                guild :: Guild.id_resolvable(),
                data :: modify_guild_options()
              ) :: api_result(Guild.t())

    @doc """
    Delete a guild.
    This operation may only be executed by the owner of the guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#delete-guild).
    """
    @doc since: "0.2.0"
    @doc section: :guild
    @callback delete_guild(guild :: Guild.id_resolvable()) :: api_result()

    @doc """
    Get all channels within a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-channels).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback get_channels(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(Channel.t()))

    @doc """
    Create a channel within a guild.
    This operation requires the `manage_channels` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild-channel).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback create_channel(
                guild :: Guild.id_resolvable(),
                data :: channel_options()
              ) :: api_result(Channel.t())

    @typedoc """
    Used to edit the position of channels using `c:modify_channel_positions/2`.

    ## Notes
    - `lock_permissions` only works when moving the channel into a new category.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions-json-params).
    """
    @typedoc since: "0.3.0"
    @type channel_positions_options ::
            %{
              required(:id) => Channel.id_resolvable(),
              optional(:position) => integer(),
              optional(:lock_permissions) => boolean(),
              optional(:parent_id) => Channel.id_resolvable()
            }
            | [
                {:id, Channel.id_resolvable()}
                | {:position, integer()}
                | {:lock_permissions, boolean()}
                | {:parent_id, Channel.id_resolvable()}
              ]

    @doc """
    Edit the positions of channels within a guild.
    This operation requires the `manage_channels` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions).
    """
    @doc since: "0.3.0"
    @doc section: :channel
    @callback modify_channel_positions(
                guild :: Guild.id_resolvable(),
                data :: [channel_positions_options()]
              ) :: api_result()

    @doc """
    Get a member of a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback get_member(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable()
              ) :: api_result(Member.t())

    @doc """
    Get a member of a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    # Shortcut
    @callback get_member(member :: Member.t()) :: api_result(Member.t())

    @typedoc """
    Used to retrieve members of a guild using `c:get_members/2`.

    ## Notes
    - `:limit` defaults to 1

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#list-guild-members-query-string-params).
    """
    @typedoc since: "0.3.0"
    @type get_members_options ::
            %{
              optional(:limit) => 1..1000,
              optional(:after) => User.id_resolvable()
            }
            | [{:limit, 1..1000}, {:after, User.id_resolvable()}]

    @doc """
    Get members of a guild.
    This operation requires the current user's application to have the `guild_members` intent enabled. (Regardless of whether any connected gateways specify it)

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    # TODO: Link gateway alternative
    @callback get_members(
                guild :: Guild.id_resolvable(),
                data :: get_members_options()
              ) :: api_result(snowflake_map(Member.t()))

    @typedoc """
    Used to retrieve members of a guild through a prefix search using `c:get_members_search/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#search-guild-members-query-string-params).
    """
    @typedoc since: "0.3.0"
    @type get_members_search_options ::
            %{
              required(:query) => String.t(),
              optional(:limit) => 1..1000
            }
            | [{:query, String.t()} | {:limit, 1..1000}]

    @doc """
    Search members of a guild using a prefix search on their usernames and nicknames.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#search-guild-members).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback get_members_search(
                guild :: Guild.id_resolvable(),
                data :: get_members_search_options()
              ) :: api_result(snowflake_map(Member.t()))

    @typedoc """
    Used to add a member to a guild using `c:create_member/3`.

    ## Notes
    - `:access_token` must have been granted the `guilds.join` scope.
    - `:nick` if provided, requires the `manage_nicknames` permission.
    - `:roles` if provided, requires the `manage_roles` permission.
    - `:mute` if provided, requires the `mute_members` permission.
    - `:deaf` if provided, requires the `deafen_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#add-guild-member-json-params).
    """
    @typedoc since: "0.3.0"
    @type create_member_options :: %{
            required(:access_token) => String.t(),
            optional(:nick) => String.t(),
            optional(:roles) => [Role.id_resolvable()],
            optional(:mute) => boolean(),
            optional(:deaf) => boolean()
          }

    @doc """
    Add a member to a guild.
    This operation requires the `create_instant_invite` permission and an oauth2 access token with the `guilds.join` scope.

    Returns no result if the member is already in the guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#add-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback create_member(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                data :: create_member_options()
              ) :: api_result() | api_result(Member.t())

    @typedoc """
    Used to edit a member within a guild.

    ## Notes
    - `:nick` if provided, requires the `manage_nicknames` permission.
    **Do not use this for the current user**, use `c:modify_current_user_nick/3` instead.
    No, this is not a joke.
    - `:roles` if provided, requires the `manage_roles` permission.
    - `:mute` if provided, requires the `mute_members` permission.
    If provided, fails if the member is not connected to any voice channel in the guild.
    - `:deaf` if provided, requires the `deafen_members` permission.
    If provided, fails if the member is not connected to any voice channel in the guild.
    - `:channel_id` if provided, requires the `move_members` permission and the current user must be able to `connect` to the target channel.
    Use `nil` to disconnect the user.
    If provided and the parameter is not `nil`, fails if the member is not connected to any voice channel in the guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-member-json-params).
    """
    @typedoc since: "0.3.0"
    @type modify_member_options ::
            %{
              optional(:nick) => String.t(),
              optional(:roles) => [Role.id_resolvable()],
              optional(:mute) => boolean(),
              optional(:deaf) => boolean(),
              optional(:channel_id) => Channel.id_resolvable() | nil,
              optional(:reason) => String.t() | nil
            }
            | [
                {:nick, String.t()}
                | {:roles, [Role.id_resolvable()]}
                | {:mute, [boolean()]}
                | {:deaf, [boolean()]}
                | {:channel_id, Channel.id_resolvable() | nil}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Edit a member in a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback modify_member(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                data :: modify_member_options()
              ) :: api_result(Member.t())

    @doc """
    Edit a member in a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback modify_member(
                member :: Member.t(),
                data :: modify_member_options()
              ) :: api_result()

    @doc """
    Edit the nick of the current user in a guild.
    This operation requires the `change_nickname` permission.

    Yes, this endpoint actually exists.

    For more information, but not an answer to the question why, see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-current-user-nick).
    """
    @doc since: "0.2.0"
    @doc section: :member
    @callback modify_current_user_nick(
                guild :: Guild.id_resolvable(),
                nick :: String.t(),
                reason :: String.t() | nil
              ) :: api_result(%{nick: String.t()})

    @doc """
    Add a role to a member.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#add-guild-member-role).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback create_member_role(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                role :: Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Add a role to a member.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#add-guild-member-role).
    """
    # Shortcut
    @doc since: "0.3.0"
    @doc section: :member
    @callback create_member_role(
                member :: Member.t(),
                role :: Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Remove a role from a member.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-member-role).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback delete_member_role(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                role :: Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Remove a role from a member.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-member-role).
    """
    @doc since: "0.3.0"
    @doc section: :member
    # Shortcut
    @callback delete_member_role(
                member :: Member.t(),
                role :: Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Kick a member from a guild.
    This operation requires the `kick_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    @callback delete_member(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Kick a member from a guild.
    This operation requires the `kick_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-member).
    """
    @doc since: "0.3.0"
    @doc section: :member
    # Shortcut
    @callback delete_member(
                member :: Member.t(),
                reason :: String.t() | nil
              ) :: api_result()

    @typedoc """
    A ban in a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#ban-object)
    """
    @typedoc since: "0.3.0"
    @type guild_ban :: %{user: User.t(), reason: String.t() | nil}

    @doc """
    Get all bans in a guild.
    This operation requires the `ban_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-bans).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    @callback get_bans(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(guild_ban()))

    @doc """
    Get all single ban in a guild, fails if no the given user is not banned.
    This operation requires the `ban_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-bans).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    @callback get_ban(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable()
              ) :: api_result(guild_ban())

    @doc """
    Get all single ban in a guild, fails if no the given user is not banned.
    This operation requires the `ban_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-ban).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    # Shortcut
    @callback get_ban(member :: Member.t()) :: api_result(guild_ban)

    @typedoc """
    Used to ban a member from a guild using `c:create_ban`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild-ban-json-params).
    """
    @typedoc since: "0.3.0"
    @type create_ban_options ::
            %{
              optional(:delete_message_days) => 0..7,
              optional(:reason) => String.t()
            }
            | [
                {:delete_message_days, 0..7}
                | {:reason, String.t()}
              ]

    @doc """
    Ban a member from a guild.
    This operation requires the `ban_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild-ban).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    @callback create_ban(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                opts :: create_ban_options()
              ) :: api_result()

    @doc """
    Ban a member from a guild.
    This operation requires the `ban_members` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild-ban).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    # Shortcut
    @callback create_ban(
                member :: Member.t(),
                opts :: create_ban_options()
              ) :: api_result()

    @doc """
    Unban a member from a guild.
    This operation requires the `ban_members` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-ban).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    @callback delete_ban(
                guild :: Guild.id_resolvable(),
                user :: User.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Unban a member from a guild.
    This operation requires the `ban_members` permissions.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#remove-guild-ban).
    """
    @doc since: "0.3.0"
    @doc section: :ban
    # Shortcut
    @callback delete_ban(
                member :: Member.t(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Get all roles in a guild.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-roles).
    """
    @doc since: "0.3.0"
    @doc section: :role
    @callback get_roles(guild :: Guild.id_resolvable()) :: api_result(snowflake_map(Role.t()))

    @typedoc """
    Used to create or edit a role using respectively `c:create_role/2` or `c:modify_role/2`.

    For more information see the Discord Developer Documentation: [create](https://discord.com/developers/docs/resources/guild#create-guild-role-json-params) or [edit](https://discord.com/developers/docs/resources/guild#modify-guild-role-json-params).
    """
    @typedoc since: "0.3.0"
    @type role_options ::
            %{
              optional(:name) => String.t(),
              optional(:permissions) => Permissions.resolvable(),
              optional(:color) => 0..0xFFFFFF,
              optional(:hoist) => boolean(),
              optional(:mentionable) => boolean(),
              optional(:reason) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:permissions, Permissions.resolvable()}
                | {:color, 0..0xFFFFFF}
                | {:hoist, boolean()}
                | {:mentionable, boolean()}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Create a role in a guild.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#create-guild-role).
    """
    @doc since: "0.3.0"
    @doc section: :role
    @callback create_role(
                guild :: Guild.id_resolvable(),
                data :: role_options()
              ) :: api_result(Role.t())

    @typedoc """
    Used to edit the position of a role using `c:modify_role_positions/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-role-positions-json-params).
    """
    @typedoc since: "0.3.0"
    @type modify_role_positions_options ::
            %{
              id: Role.id_resolvable(),
              position: integer()
            }
            | [
                {:id, Role.id_resolvable()}
                | {:position, integer()}
              ]

    @doc """
    Edit the position of roles.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-role-positions).
    """
    @doc since: "0.3.0"
    @doc section: :role
    @callback modify_role_positions(
                guild :: Guild.id_resolvable(),
                data :: modify_role_positions_options()
              ) :: api_result(snowflake_map(Role.t()))

    @doc """
    Edit a role.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-role).
    """
    @doc since: "0.3.0"
    @doc section: :role
    @callback modify_role(
                guild :: Guild.id_resolvable(),
                role :: Role.id_resolvable(),
                data :: role_options()
              ) :: api_result(Role.t())

    @doc """
    Edit a role.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-role).
    """
    @doc since: "0.3.0"
    @doc section: :role
    # Shortcut
    @callback modify_role(
                role :: Role.t(),
                data :: role_options()
              ) :: api_result(Role.t())

    @doc """
    Delete a role.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#delete-guild-role).
    """
    @doc since: "0.3.0"
    @doc section: :role
    @callback delete_role(
                guild :: Guild.id_resolvable(),
                role :: Role.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @doc """
    Delete a role.
    This operation requires the `manage_roles` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#delete-guild-role).
    """
    @doc since: "0.3.0"
    @doc section: :role
    # Shortcut
    @callback delete_role(role :: Role.t(), reason :: String.t() | nil) :: api_result()

    @typedoc """
    Used to prune guild members or get the count of to-be pruned guild members using respectively `c:create_prune/2` or `c:get_prune_count/2`.

    `:compute_prune_count` only has effect in `c:create_prune/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#begin-guild-prune-json-params).
    """
    @typedoc since: "0.3.0"
    @type prune_options ::
            %{
              optional(:days) => 1..30,
              optional(:include_roles) => [Role.id_resolvable()],
              optional(:compute_prune_count) => boolean()
            }
            | [
                {:days, 1..30}
                | {:include_roles, [Role.id_resolvable()]}
                | {:compute_prune_count, boolean()}
              ]

    @doc """
    Calculate the amount of members that would have been removed in a prune operation.
    Requires the `kick_members` permission.

    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_prune_count(
                guild :: Guild.id_resolvable(),
                opts :: prune_options()
              ) ::
                api_result(%{pruned: non_neg_integer()})

    @doc """
    Prunes inactive members.
    Requires the `kick_members` permission.

    For large guilds it's recommend to set `compute_prune_count` to `false`, making `pruned` return `nil`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#begin-guild-prune).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback create_prune(
                guild :: Guild.id_resolvable(),
                opts :: prune_options()
              ) :: api_result(%{pruned: non_neg_integer() | nil})

    @doc """
    Get all voice regions a guild can use, this includes `VIP servers` if the guild is eligible.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-voice-regions).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_voice_regions(guild :: Guild.id_resolvable()) ::
                api_result(%{required(name :: String.t()) => VoiceRegion.t()})

    @doc """
    Get all invites of a guild.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-invites).
    """
    @doc since: "0.2.0"
    @doc section: :invite
    @callback get_guild_invites(guild :: Guild.id_resolvable()) ::
                api_result(%{required(code :: String.t()) => Invite.t()})

    @doc """
    Get all integrations of a guild.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-integrations).
    """
    @doc since: "0.3.0"
    @doc section: :integration
    @callback get_integrations(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(Integration.t()))
    @doc """
    Delete an integration.
    This operation requires the `manage_guild` operation.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#delete-guild-integration).
    """
    @doc since: "0.3.0"
    @doc section: :integration
    @callback delete_integration(
                guild :: Guild.id_resolvable(),
                integration :: Integration.id_resolvable(),
                reason :: String.t() | nil
              ) :: api_result()

    @typedoc """
    Guild widget settings.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#guild-widget-object).
    """
    @typedoc since: "0.3.0"
    @type guild_widget_settings :: %{enabled: boolean(), channel_id: Snowflake.t() | nil}

    @doc """
    Get the guild widget settings.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-widget-settings).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_guild_widget_settings(guild :: Guild.id_resolvable()) ::
                api_result(guild_widget_settings())

    @doc """
    Edit a guild embed.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-embed).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback modify_guild_widget_settings(
                guild :: Guild.id_resolvable(),
                data ::
                  %{
                    optional(:reason) => String.t() | nil,
                    enabled: boolean(),
                    channel_id: Channel.id_resolvable() | nil
                  }
                  | [
                      {:enabled, boolean()}
                      | {:channel_id, Channel.id_resolvable() | nil}
                      | {:reason, String.t() | nil}
                    ]
              ) :: api_result(guild_widget_settings())

    @doc """
    Get a guild's widget json.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-widget).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_guild_widget(guild :: Guild.id_resolvable()) :: api_result(map())

    @doc """
    Get a partial invote for the vanity invite of a guild.
    This operation requires the `manage_guild` permission.

    ## Notes
    - `:code` will be nil if no vanity invite is set.
    - `:code` is only the code, not the full url.
    - The operation will fail if the guild is not eligible to set a vanity invite.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-vanity-url).
    """
    @doc since: "0.3.0"
    @doc section: :invite
    @callback get_vanity_url(guild :: Guild.id_resolvable()) ::
                api_result(%{code: String.t() | nil, uses: non_neg_integer()})

    # No get guild widget image, because it does not return JSON but just the plain image.
    # Also does not require authorization.

    @doc """
    Get the welcome screen of a guild.

    > Returns `:ok` if no welcome screen is set up.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#get-guild-welcome-screen).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback get_guild_welcome_screen(guild :: Guild.id_resolvable()) ::
                api_result(Guild.welcome_screen())

    @typedoc """
    Used to modify the welcome screen of a guild using `c:modify_guild_welcome_screen/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-welcome-screen).
    """
    @typedoc since: "0.3.0"
    @type modify_guild_welcome_screen_options :: %{
            optional(:enabled) => boolean() | nil,
            optional(:welcome_channels) =>
              [
                welcome_channel :: %{
                  channel_id: Channel.id_resolvable(),
                  description: String.t(),
                  emoji_id: Emoji.id_resolvable() | nil,
                  emoji_name: String.t() | nil
                }
              ]
              | nil,
            optional(:description) => String.t() | nil
          }

    @doc """
    Modify the welcome screen of a guild.
    This operation requires either the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/guild#modify-guild-welcome-screen).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    @callback modify_guild_welcome_screen(
                guild :: Guild.id_resolvable(),
                options :: modify_guild_welcome_screen_options()
              ) :: api_result(Guild.welcome_screen())

    ###
    # Guild END
    ###

    ###
    # Invite START
    ###

    @typedoc """
    Used to get member counts when getting an invite using `c:get_invite/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/invite#get-invite-get-invite-url-parameters).
    """
    @typedoc since: "0.3.0"
    @type get_invite_options ::
            %{
              optional(:with_counts) => boolean()
            }
            | [{:with_counts, boolean()}]

    @doc """
    Get an invite.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/invite#get-invite).
    """
    @doc since: "0.2.0"
    @doc section: :invite
    @callback get_invite(code :: String.t(), opts :: get_invite_options()) ::
                api_result(Invite.t())

    @doc """
    Delete an invite.
    This operation requires either the `manage_guild` permission or the `manage_channels` permission on the channel of the invite.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/invite#delete-invite).
    """
    @doc since: "0.2.0"
    @doc section: :invite
    @callback delete_invite(
                code :: String.t(),
                reason :: String.t() | nil
              ) :: api_result(Invite.t())

    ###
    # Invite END
    ###

    ###
    # Template START
    ###

    @doc """
    Get a guild template.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#get-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback get_template(template :: Template.code_resolvable()) :: api_result(Template.t())

    @typedoc """
    Used to create a guild from a template using `c:create_guild_from_template/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#create-guild-from-template-json-params).
    """
    @typedoc since: "0.3.0"
    @type create_guild_from_template_options ::
            %{
              required(:name) => String.t(),
              optional(:icon) => image_options()
            }
            | [{:name, String.t()} | {:icon, image_options()}]

    @doc """
    Create a guild from a template object.

    > This operation can not be used by bots that are in more than 9 guilds.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#create-guild-from-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback create_guild_from_template(
                template :: Template.code_resolvable(),
                opts :: create_guild_from_template_options
              ) :: api_result(Guild.t())

    @doc """
    Get guild templates.
    This operation requires `manage_guild` permission.

    Guilds currently can only have one template.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#get-guild-templates).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback get_templates(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(Template.t()))

    @typedoc """
    Used to create or modify a guild template using `c:create_template/2` or `c:modify_template/3`.

    ## Notes
    - When creating a template, `:name` is required.
    - `:name` must be [1, 100] characters long.
    - `:description` must be [0, 120] characters long.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#create-guild-template-json-params).
    """
    @typedoc since: "0.3.0"
    @type template_options ::
            %{
              optional(:name) => String.t(),
              optional(:description) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:description, String.t() | nil}
              ]
    @doc """
    Create a template for a guild.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#create-guild-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback create_template(
                guild :: Guild.id_resolvable(),
                opts :: template_options()
              ) :: api_result(Template.t())

    @doc """
    Sync a guild template.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#sync-guild-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    # Ignore naming here
    @callback sync_template(
                guild :: Guild.id_resolvable(),
                template :: Template.code_resolvable()
              ) :: api_result(Template.t())

    @doc """
    Modify a guild template's metadata.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#modify-guild-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback modify_template(
                guild :: Guild.id_resolvable(),
                template :: Template.code_resolvable(),
                opts :: template_options()
              ) :: api_result(Template.t())

    @doc """
    Delete a guild template.
    This operation requires the `manage_guild` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/template#delete-guild-template).
    """
    @doc since: "0.3.0"
    @doc section: :template
    @callback delete_template(
                guild :: Guild.id_resolvable(),
                template :: Template.code_resolvable()
              ) :: api_result(Template.t())

    ###
    # Template END
    ###

    ###
    # User START
    ###

    @doc """
    Get the currently logged in user.

    Note that the OAuth2 part of this endpoint's documentation does not apply to bots.
    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#get-current-user).
    """
    @doc since: "0.2.1"
    @doc section: :user
    # TODO: mfa_enabled?
    @callback get_current_user() :: api_result(User.t())

    @doc """
    Get a user.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#get-user).
    """
    @doc since: "0.2.0"
    @doc section: :user
    @callback get_user(user :: User.id_resolvable()) :: api_result(User.t())

    @typedoc """
    Used to edit the currently logged in user using `c:modify_current_user/1`.

    There are some limitations around usernames, see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#usernames-and-nicknames).

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#modify-current-user-json-params).
    """
    @typedoc since: "0.3.0"
    @type modify_current_user_options ::
            %{
              optional(:username) => String.t(),
              optional(:avatar) => image_options()
            }
            | [
                {:username, String.t()}
                | {:avatar, image_options()}
              ]

    @doc """
    Edit the currently logged in user.

    Note that verified bots may not change their avatar through this function and have to go through support instead.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#modify-current-user).
    """
    @doc since: "0.2.0"
    @doc section: :user
    @callback modify_current_user(opts :: modify_current_user_options()) :: api_result(User.t())

    @typedoc """
    Used to obtain guilds the currently logged in user is a member of using `c:get_current_user_guilds/1`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#get-current-user-guilds-query-string-params).
    """
    @typedoc since: "0.3.0"
    @type get_current_user_guilds_options ::
            %{
              optional(:before) => Guild.id_resolvable(),
              optional(:after) => Guild.id_resolvable(),
              optional(:limit) => 1..100
            }
            | [
                {:before, Guild.id_resolvable()}
                | {:after, Guild.id_resolvable()}
                | {:limit, 1..100}
              ]

    @doc """
    Get a list of **partial** guilds the currently logged in user is a member of.

    A partial guild's info includes:
    - `:id`
    - `:name`
    - `:icon`
    - `:owner`
    - `:permissions` - permissions of the currently logged in user

    Note that the OAuth2 part of this endpoint's documentation does not apply to bots.
    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#get-current-user-guilds).
    """
    @doc since: "0.2.0"
    @doc section: :user
    @callback get_current_user_guilds(opts :: get_current_user_guilds_options()) ::
                api_result(snowflake_map(Guild.t()))

    @doc """
    Leave a guild.
    Fails if the currently logged in user owns it.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#leave-guild).
    """
    @doc since: "0.3.0"
    @doc section: :guild
    # TODO: naming
    @callback leave_guild(guild :: Guild.id_resolvable()) :: api_result()

    # No Get User DMS
    # Does not work for bots anymore.
    # No clue why it is still documented.

    @doc """
    Create or reopen a dm channel with a user.

    ## Notes
    - Opening a DM to an existing user always works, if the target is not the logged in user.
    - Sending a DM to bots however _always_ will fail.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/user#create-dm).
    """
    @doc since: "0.2.0"
    @doc section: :user
    @callback create_dm(user :: User.id_resolvable()) :: api_result(Channel.t())

    # No create group dm

    # No get user connections

    ###
    # User END
    ###

    ###
    # Voice START
    ###

    @doc """
    Get a list of voice regions that can be used when creating a guild.

    To get a list of voice regions you can use for a specific guild use `c:get_voice_regions/1` instead.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/voice#list-voice-regions).
    """
    @doc since: "0.3.0"
    @doc section: :voice
    @callback get_voice_regions() ::
                api_result(%{required(name :: String.t()) => VoiceRegion.t()})

    ###
    # Voice END
    ###

    ###
    # Webhook START
    ###

    @typedoc """
    Used to create a webhook using `c:create_webhook/2`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#create-webhook-json-params).
    """
    @typedoc since: "0.3.0"
    @type create_webhook_options ::
            %{
              required(:name) => String.t(),
              optional(:avatar) => image_options(),
              optional(:reason) => String.t() | nil
            }
            | [
                {:name, String.t()}
                | {:avatar, image_options()}
                | {:reason, String.t() | nil}
              ]

    @doc """
    Create a new webhook.
    This operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#create-webhook).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback create_webhook(
                channel :: Channel.id_resolvable(),
                opts :: create_webhook_options()
              ) :: api_result(Webhook.t())

    @doc """
    Get all webhooks in a channel.
    This operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#get-channel-webhooks).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback get_channel_webhooks(channel :: Channel.id_resolvable()) ::
                api_result(snowflake_map(Webhook.t()))

    @doc """
    Get all webhooks in a guild.
    This operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#get-guild-webhooks).
    """
    @doc since: "0.2.0"
    @doc section: :webhook
    @callback get_guild_webhooks(guild :: Guild.id_resolvable()) ::
                api_result(snowflake_map(Webhook.t()))

    @doc """
    Get a webhook.

    ## Notes
    - If a `t:Webhook.t/0` is being used, the resulting webhook does not include a `:user`.
    - If a `t:Webhook.id_resolvable/0` is being used, this operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#get-guild-webhooks).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback get_webhook(webhook :: Webhook.t() | Webhook.id_resolvable()) ::
                api_result(snowflake_map(Webhook.t()))

    @doc """
    Get a webhook.

    ## Notes
    - The resulting webhook does not include a `:user`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#get-webhook-with-token).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback get_webhook(webhook :: Webhook.id_resolvable(), token :: String.t()) ::
                api_result(Webhook.t())

    @typedoc """
    Used to edit a webhook using `c:modify_webhook/2,3`.

    ## Notes
    - If using `c:modify_webhook/3` or `c:modify_webhook/2` with a `t:Crux.Structs.Webhook.t/0`, `:channel_id` and `:reason` are not a valid options and will be silently ignored.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#modify-webhook-json-params).
    """
    @typedoc since: "0.3.0"
    @type modify_webhook_options :: %{
            optional(:name) => String.t(),
            optional(:avatar) => image_options(),
            optional(:channel_id) => Channel.id_resolvable(),
            optional(:reason) => String.t() | nil
          }

    @doc """
    Edit a webhook.
    If a `t:Crux.Structs.Webhook.id_resolvable/0` is being used, this operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#modify-webhook).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback modify_webhook(
                webhook :: Webhook.id_resolvable(),
                opts :: modify_webhook_options()
              ) :: api_result(Webhook.t())

    @callback modify_webhook(
                webhook :: Webhook.t(),
                partial_opts :: modify_webhook_options()
              ) :: api_result(Webhook.t())

    @doc """
    Edit a webhook.

    The resulting webhook does not include a `:user`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback modify_webhook(
                webhook :: Webhook.id_resolvable(),
                token :: String.t(),
                partial_opts :: modify_webhook_options()
              ) :: api_result(Webhook.t())

    @doc """
    Delete a webhook.
    If not using a token, this operation requires the `manage_webhooks` permission.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#delete-webhook).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback delete_webhook(
                webhook :: Webhook.id_resolvable(),
                opts :: %{optional(:reason) => String.t() | nil} | [{:reason, String.t() | nil}]
              ) :: api_result()

    @callback delete_webhook(webhook :: Webhook.id_resolvable(), token :: String.t()) ::
                api_result()

    @typedoc """
    Used to send a message with a webhook using `c:create_webhook_message/2,3`.

    ## Notes
    - `:type` what kind of flavor to use, defaults to `:discord`
    - `:event` only applies to the type `:github`
    - `:wait` whether to wait for the server to confirm that the message was sent, defaults to `true`
    - `:files` has a maximum of 10
    - `:embeds` has a maximum of 10

    Note that the documented types are only for Discord, for Slack and GitHub refer to their documentations linked below.

    For more information see the relevant Documentation:
    - [Discord](https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params)
    - [Slack](https://api.slack.com/messaging/webhooks)
    - [Github](https://developer.github.com/webhooks/)
    """
    @typedoc since: "0.3.0"
    @type create_webhook_message_options ::
            %{
              optional(:type) => :discord | :slack | :github | String.t(),
              optional(:event) => String.t(),
              optional(:wait) => boolean(),
              optional(:content) => String.t(),
              optional(:username) => String.t(),
              optional(:avatar_url) => String.t(),
              optional(:tts) => boolean(),
              optional(:files) => [file_options()],
              optional(:embeds) => [Embed.t() | embed_options()],
              optional(:allowed_mentions) => allowed_mentions_options()
            }
            | [
                {:type, :discord | :slack | :github | String.t()}
                | {:event, String.t()}
                | {:wait, boolean()}
                | {:content, String.t()}
                | {:username, String.t()}
                | {:avattar_url, String.t()}
                | {:tts, boolean()}
                | {:files, [file_options()]}
                | {:embeds, [Embed.t() | embed_options()]}
                | {:allowed_mentions, allowed_mentions_options()}
              ]

    @doc """
    Send a message using a webhook.

    Note that only a message sent using the `:discord` `:type` that was `:wait`ed for will return a `t:Message.t/0`.

    For more information see the Discord Developer Documentation:
    - [default](https://discord.com/developers/docs/resources/webhook#execute-webhook)
    - [Slack-Compatible](https://discord.com/developers/docs/resources/webhook#execute-slackcompatible-webhook)
    - [Github-Compatible](https://discord.com/developers/docs/resources/webhook#execute-githubcompatible-webhook)
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback create_webhook_message(
                webhook :: Webhook.t(),
                opts :: create_webhook_message_options()
              ) :: api_result() | api_result(Message.t())

    @doc """
    Send a message using a webhook.

    Note that only a message sent using the `:discord` `:type` that was `:wait`ed for will return a `t:Message.t/0`.

    For more information see the Discord Developer Documentation:
    - [default](https://discord.com/developers/docs/resources/webhook#execute-webhook)
    - [Slack-Compatible](https://discord.com/developers/docs/resources/webhook#execute-slackcompatible-webhook)
    - [Github-Compatible](https://discord.com/developers/docs/resources/webhook#execute-githubcompatible-webhook)
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback create_webhook_message(
                webhook :: Webhook.id_resolvable(),
                token :: String.t(),
                opts :: create_webhook_message_options()
              ) ::
                api_result() | api_result(Message.t())

    @typedoc """
    Used to edit a message sent by a webhook using `c:modify_webhook_message/4`.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#edit-webhook-message-jsonform-params).
    """
    @typedoc since: "0.3.0"
    @type modify_webhook_message_options ::
            %{
              optional(:content) => String.t() | nil,
              optional(:embeds) => [Embed.t() | embed_options()] | nil,
              optional(:files) => [file_options()],
              optional(:allowed_mentions) => allowed_mentions_options() | nil
            }
            | [
                {:content, String.t() | nil}
                | {:embeds, [Embed.t() | embed_options()] | nil}
                | {:files, [file_options()]}
                | {:allowed_mentions, allowed_mentions_options() | nil}
              ]

    @doc """
    Edit a message sent by a webhook.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#edit-webhook-message).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback modify_webhook_message(
                webhook :: Webhook.id_resolvable(),
                token :: String.t(),
                message :: Message.id_resolvable(),
                opts :: modify_webhook_message_options()
              ) :: api_result(Message.t())

    @doc """
    Delete a message sent by a webhook.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/webhook#delete-webhook-message).
    """
    @doc since: "0.3.0"
    @doc section: :webhook
    @callback delete_webhook_message(
                webhook :: Webhook.id_resolvable(),
                token :: String.t(),
                message :: Message.id_resolvable()
              ) :: api_result()

    ###
    # Webhook END
    ###

    ###
    # Gateway
    ###

    @doc """
    Get the currently valid WSS URL.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/topics/gateway#get-gateway).
    """
    @doc since: "0.3.0"
    @doc section: :gateway
    @callback get_gateway() :: api_result(%{url: String.t()})

    @doc """
    Get the currently valid WSS URL and additional metadata.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/topics/gateway#get-gateway).
    """
    @doc since: "0.3.0"
    @doc section: :gateway
    @callback get_gateway_bot() ::
                api_result(%{
                  url: String.t(),
                  shards: non_neg_integer(),
                  session_start_limit: %{
                    total: non_neg_integer(),
                    remaining: non_neg_integer(),
                    reset_after: non_neg_integer()
                  }
                })

    ###
    # Gateway END
    ###

    ###
    # OAuth2 START
    ###

    @doc """
    Get the currently logged in user's OAuth2 application info.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/topics/oauth2#get-current-application-information).
    """
    @doc since: "0.3.0"
    @doc section: :oauth2
    @callback get_current_application() :: api_result(Application.t())

    @typedoc """
    Info about an authorization.

    The application is partial, missing owner, team, and other optional fields.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/topics/oauth2#get-current-authorization-information-response-structure).
    """
    @typedoc since: "0.3.0"
    @type authorization_information :: %{
            required(:application) => Application.t(),
            required(:scopes) => [String.t()],
            required(:expires) => String.t(),
            optional(:user) => User.t()
          }

    @doc """
    Get info about the current authorization.

    > This will use the provided bearer token instead of the otherwise configured authorization.

    For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/topics/oauth2#get-current-authorization-information).
    """
    @doc since: "0.3.0"
    @doc section: :oauth2
    @callback get_current_authorization_information(bearer :: String.t()) :: api_result(map())

    ###
    # OAuth2 END
    ###
    # bangify end
  end
end
