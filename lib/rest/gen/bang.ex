defmodule Crux.Rest.Gen.Bang do
  @moduledoc false
  # Generated 2019-11-19T15:54:58.759000Z

  alias Crux.Rest.Version
  require Version

  defmacro __using__(:callbacks) do
    quote location: :keep do
      @doc "The same as `c:add_guild_member/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_guild_member!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  user :: Crux.Structs.User.id_resolvable(),
                  data :: Crux.Rest.add_guild_member_data()
                ) :: Crux.Structs.Member.t() | no_return()

      @doc "The same as `c:add_guild_member_role/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_guild_member_role!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  member :: Crux.Structs.User.id_resolvable(),
                  role :: Crux.Structs.Role.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:add_pinned_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      @doc "The same as `c:add_pinned_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_pinned_message!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:begin_guild_prune/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback begin_guild_prune!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  opts :: Crux.Rest.begin_guild_prune_opts()
                ) :: non_neg_integer() | no_return()

      @doc "The same as `c:create_channel_invite/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_channel_invite!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  args :: Crux.Rest.create_channel_invite_data()
                ) :: Crux.Structs.Invite.t() | no_return()

      @doc "The same as `c:create_dm/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_dm!(user :: Crux.Structs.User.id_resolvable()) ::
                  Crux.Structs.Channel.t() | no_return()

      @doc "The same as `c:create_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild!(term()) :: Crux.Structs.Guild.t() | no_return()

      @doc "The same as `c:create_guild_ban/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_ban!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  user :: Crux.Structs.User.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:create_guild_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_channel!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data :: Crux.Rest.create_guild_channel_data()
                ) :: Crux.Structs.Channel.t() | no_return()

      @doc "The same as `c:create_guild_emoji/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_emoji!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data :: Crux.Rest.create_guild_emoji_data()
                ) :: Crux.Structs.Emoji | no_return()

      @doc "The same as `c:create_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_integration!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data ::
                    %{
                      required(:type) => String.t(),
                      required(:id) => Crux.Structs.Snowflake.resolvable()
                    }
                    | [{:type, String.t()} | {:id, Crux.Structs.Snowflake.resolvable()}]
                ) :: :ok | no_return()

      @doc "The same as `c:create_guild_role/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_role!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data :: Crux.Rest.guild_role_data()
                ) :: Crux.Structs.Role.t() | no_return()

      @doc "The same as `c:create_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_message!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  args :: Crux.Rest.create_message_data()
                ) :: Crux.Structs.Message.t() | no_return()

      @doc "The same as `c:create_reaction/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_reaction!(
                  message :: Crux.Structs.Message.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:create_reaction/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_reaction!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_all_reactions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_all_reactions!(
                  message :: Crux.Structs.Message.t(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_all_reactions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_all_reactions!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_channel!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  reason :: String.t() | nil
                ) :: Crux.Structs.Channel.t() | no_return()

      @doc "The same as `c:delete_channel_permissions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_channel_permissions!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  target :: Crux.Structs.Overwrite.target_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:delete_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild!(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | no_return()

      @doc "The same as `c:delete_guild_emoji/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_emoji!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:delete_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_integration!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  integration_id :: Crux.Structs.Snowflake.resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_guild_role/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_role!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  role :: Crux.Structs.Role.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:delete_invite/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_invite!(invite_or_code :: String.t() | Crux.Structs.Invite.t()) ::
                  Crux.Structs.Invite.t() | no_return()

      @doc "The same as `c:delete_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      @doc "The same as `c:delete_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_message!(
                  channel_id :: Crux.Structs.Channel.id_resolvable(),
                  message_id :: Crux.Structs.Message.id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_messages/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_messages!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  messages :: [Crux.Structs.Message.id_resolvable()]
                ) :: :ok | no_return()

      @doc "The same as `c:delete_pinned_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      @doc "The same as `c:delete_pinned_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_pinned_message!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_reaction/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_reaction!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable(),
                  user :: Crux.Structs.User.id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_webhook!(
                  user :: Crux.Structs.User.id_resolvable(),
                  token :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:edit_channel_permissions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_channel_permissions!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  target :: Crux.Structs.Overwrite.target_resolvable(),
                  data :: Crux.Rest.edit_channel_permissions_data()
                ) :: :ok | no_return()

      @doc "The same as `c:edit_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_message!(
                  target :: Crux.Structs.Message.t(),
                  args :: Crux.Rest.message_edit_data()
                ) :: Crux.Structs.Message.t() | no_return()

      @doc "The same as `c:edit_message/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_message!(
                  channel_id :: Crux.Structs.Channel.id_resolvable(),
                  message_id :: Crux.Structs.Message.id_resolvable(),
                  args :: Crux.Rest.message_edit_data()
                ) :: Crux.Structs.Message.t() | no_return()

      @doc "The same as `c:execute_github_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_github_webhook!(
                  webhook :: Crux.Structs.Webhook.t(),
                  event :: String.t(),
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_github_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_github_webhook!(
                  webhook :: Crux.Structs.Webhook.t(),
                  event :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_github_webhook/5`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_github_webhook!(
                  user :: Crux.Structs.User.id_resolvable(),
                  token :: String.t(),
                  event :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_slack_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_slack_webhook!(webhook :: Crux.Structs.Webhook.t(), data :: term()) ::
                  :ok | no_return()

      @doc "The same as `c:execute_slack_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_slack_webhook!(
                  webhook :: Crux.Structs.Webhook.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_slack_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_slack_webhook!(
                  user :: Crux.Structs.User.id_resolvable(),
                  token :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_webhook!(
                  webhook :: Crux.Structs.Webhook.t(),
                  data :: Crux.Rest.execute_webhook_options()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_webhook!(
                  webhook :: Crux.Structs.Webhook.t(),
                  wait :: boolean() | nil,
                  data :: Crux.Rest.execute_webhook_options()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_webhook!(
                  user :: Crux.Structs.User.id_resolvable(),
                  token :: String.t(),
                  wait :: boolean() | nil,
                  data :: Crux.Rest.execute_webhook_options()
                ) :: :ok | no_return()

      @doc "The same as `c:gateway/0`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback gateway!() :: term() | no_return()

      @doc "The same as `c:gateway_bot/0`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback gateway_bot!() :: term() | no_return()

      @doc "The same as `c:get_audit_logs/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_audit_logs!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  options :: Crux.Rest.audit_log_options() | nil
                ) :: Crux.Structs.AuditLog.t() | no_return()

      @doc "The same as `c:get_channel/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_channel!(channel :: Crux.Structs.Channel.id_resolvable()) ::
                  Crux.Structs.Channel.t() | no_return()

      @doc "The same as `c:get_channel_invites/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_channel_invites!(channel :: Crux.Structs.Channel.id_resolvable()) ::
                  %{required(String.t()) => Crux.Structs.Invite.t()} | no_return()

      @doc "The same as `c:get_current_user/0`, but raises an exception if it fails."
      Version.since("0.2.1")

      @callback get_current_user!() :: Crux.Structs.User.t() | no_return()

      @doc "The same as `c:get_current_user_guilds/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_current_user_guilds!(data :: Crux.Rest.get_current_user_guild_data()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Guild.t()} | no_return()

      @doc "The same as `c:get_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  Crux.Structs.Guild.t() | no_return()

      @doc "The same as `c:get_guild_ban/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_ban!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  user :: Crux.Structs.User.id_resolvable()
                ) ::
                  %{
                    required(:user) => Crux.Structs.User.t(),
                    required(:reason) => String.t() | nil
                  }
                  | no_return()

      @doc "The same as `c:get_guild_bans/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_bans!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{
                    required(Crux.Structs.Snowflake.t()) => %{
                      required(:user) => Crux.Structs.User.t(),
                      required(:reason) => String.t() | nil
                    }
                  }
                  | no_return()

      @doc "The same as `c:get_guild_channels/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_channels!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Channel.t()}
                  | no_return()

      @doc "The same as `c:get_guild_embed/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_embed!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  term() | no_return()

      @doc "The same as `c:get_guild_emoji/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_emoji!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.id_resolvable()
                ) :: Crux.Structs.Emoji | no_return()

      @doc "The same as `c:get_guild_integrations/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_integrations!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  list() | no_return()

      @doc "The same as `c:get_guild_invites/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_invites!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{required(String.t()) => Crux.Structs.Invite.t()} | no_return()

      @doc "The same as `c:get_guild_member/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_member!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  user :: Crux.Structs.User.id_resolvable()
                ) :: Crux.Structs.Member.t() | no_return()

      @doc "The same as `c:get_guild_prune_count/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_prune_count!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  days :: pos_integer()
                ) :: non_neg_integer() | no_return()

      @doc "The same as `c:get_guild_roles/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_roles!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()} | no_return()

      @doc "The same as `c:get_guild_vanity_invite/1`, but raises an exception if it fails."
      Version.since("0.2.1")

      @callback get_guild_vanity_invite!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  Crux.Structs.Invite.t() | no_return()

      @doc "The same as `c:get_guild_vanity_url/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      Version.deprecated("Use get_guild_vanity_invite/1 instead")

      @callback get_guild_vanity_url!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  String.t() | no_return()

      @doc "The same as `c:get_guild_voice_regions/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_voice_regions!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  term() | no_return()

      @doc "The same as `c:get_invite/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_invite!(code :: String.t()) :: Crux.Structs.Invite.t() | no_return()

      @doc "The same as `c:get_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_message!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message_id :: Crux.Structs.Message.id_resolvable()
                ) :: Crux.Structs.Message.t() | no_return()

      @doc "The same as `c:get_messages/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_messages!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  args :: Crux.Rest.get_messages_data()
                ) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()}
                  | no_return()

      @doc "The same as `c:get_pinned_messages/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_pinned_messages!(channel :: Crux.Structs.Channel.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()}
                  | no_return()

      @doc "The same as `c:get_reactions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_reactions!(
                  message :: Crux.Structs.Message.t(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable(),
                  args :: Crux.Rest.get_reactions_data()
                ) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.User.t()} | no_return()

      @doc "The same as `c:get_reactions/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_reactions!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  message :: Crux.Structs.Message.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.identifier_resolvable() | list(),
                  args :: Crux.Rest.get_reactions_data()
                ) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.User.t()} | no_return()

      @doc "The same as `c:get_user/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_user!(user :: Crux.Structs.User.id_resolvable()) ::
                  Crux.Structs.User.t() | no_return()

      @doc "The same as `c:get_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_webhook!(user :: Crux.Structs.User.id_resolvable(), token :: String.t() | nil) ::
                  Crux.Structs.Webhook.t() | no_return()

      @doc "The same as `c:leave_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback leave_guild!(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | no_return()

      @doc "The same as `c:list_channel_webhooks/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_channel_webhooks!(channel :: Crux.Structs.Channel.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()}
                  | no_return()

      @doc "The same as `c:list_guild_emojis/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_emojis!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Emoji.t()} | no_return()

      @doc "The same as `c:list_guild_members/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_members!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  options :: Crux.Rest.list_guild_members_options()
                ) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Member.t()} | no_return()

      @doc "The same as `c:list_guild_webhooks/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_webhooks!(guild :: Crux.Structs.Guild.id_resolvable()) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()}
                  | no_return()

      @doc "The same as `c:modify_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_channel!(
                  channel :: Crux.Structs.Channel.id_resolvable(),
                  data :: Crux.Rest.modify_channel_data()
                ) :: Crux.Structs.Channel.t() | no_return()

      @doc "The same as `c:modify_current_user/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_current_user!(data :: Crux.Rest.modify_current_user_data()) ::
                  Crux.Structs.User.t() | no_return()

      @doc "The same as `c:modify_current_users_nick/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_current_users_nick!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  nick :: String.t(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:modify_guild/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data :: Crux.Rest.modify_guild_data()
                ) :: Crux.Structs.Guild.t() | no_return()

      @doc "The same as `c:modify_guild_channel_positions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_channel_positions!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  channels :: [Crux.Structs.Channel.position_resolvable()]
                ) :: :ok | no_return()

      @doc "The same as `c:modify_guild_embed/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_embed!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data ::
                    %{
                      optional(:enabled) => boolean(),
                      optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                    }
                    | [
                        {:enabled, boolean()}
                        | {:channel_id, Crux.Structs.Channel.id_resolvable()}
                      ]
                ) :: term() | no_return()

      @doc "The same as `c:modify_guild_emoji/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_emoji!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  emoji :: Crux.Structs.Emoji.id_resolvable(),
                  data :: Crux.Rest.modify_guild_emoji_data()
                ) :: Crux.Structs.Emoji | no_return()

      @doc "The same as `c:modify_guild_integration/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_integration!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  integration_id :: Crux.Structs.Snowflake.resolvable(),
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
                ) :: :ok | no_return()

      @doc "The same as `c:modify_guild_member/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_member!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  member :: Crux.Structs.User.id_resolvable(),
                  data :: Crux.Rest.modify_guild_member_data()
                ) :: :ok | no_return()

      @doc "The same as `c:modify_guild_role/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_role!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  role :: Crux.Structs.Role.id_resolvable(),
                  data :: Crux.Rest.guild_role_data()
                ) :: Crux.Structs.Role.t() | no_return()

      @doc "The same as `c:modify_guild_role_positions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_role_positions!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  data :: [Crux.Structs.Role.position_resolvable()]
                ) ::
                  %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()} | no_return()

      @doc "The same as `c:remove_guild_ban/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback remove_guild_ban!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  user :: Crux.Structs.User.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:remove_guild_member_role/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback remove_guild_member_role!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  member :: Crux.Structs.User.id_resolvable(),
                  role :: Crux.Structs.Role.id_resolvable(),
                  reason :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:sync_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback sync_guild_integration!(
                  guild :: Crux.Structs.Guild.id_resolvable(),
                  integration_id :: Crux.Structs.Snowflake.resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:trigger_typing/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback trigger_typing!(channel :: Crux.Structs.Channel.id_resolvable()) ::
                  :ok | no_return()

      @doc "The same as `c:update_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback update_webhook!(
                  user :: Crux.Structs.User.id_resolvable(),
                  token :: String.t() | nil,
                  data ::
                    %{
                      optional(:name) => String.t(),
                      optional(:avatar) => Crux.Rest.Util.image(),
                      optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                    }
                    | [
                        {:name, String.t()}
                        | {:avatar, Crux.Rest.Util.image()}
                        | {:channel_id, Crux.Structs.Channel.id_resolvable()}
                      ]
                ) :: Crux.Structs.Webhook.t() | no_return()

      # Required for `Crux.Rest.Functions`
      @optional_callbacks add_guild_member!: 3,
                          add_guild_member_role!: 4,
                          add_pinned_message!: 1,
                          add_pinned_message!: 2,
                          begin_guild_prune!: 2,
                          create_channel_invite!: 2,
                          create_dm!: 1,
                          create_guild!: 1,
                          create_guild_ban!: 3,
                          create_guild_channel!: 2,
                          create_guild_emoji!: 2,
                          create_guild_integration!: 2,
                          create_guild_role!: 2,
                          create_message!: 2,
                          create_reaction!: 2,
                          create_reaction!: 3,
                          delete_all_reactions!: 2,
                          delete_all_reactions!: 3,
                          delete_channel!: 2,
                          delete_channel_permissions!: 3,
                          delete_guild!: 1,
                          delete_guild_emoji!: 3,
                          delete_guild_integration!: 2,
                          delete_guild_role!: 3,
                          delete_invite!: 1,
                          delete_message!: 1,
                          delete_message!: 2,
                          delete_messages!: 2,
                          delete_pinned_message!: 1,
                          delete_pinned_message!: 2,
                          delete_reaction!: 4,
                          delete_webhook!: 2,
                          edit_channel_permissions!: 3,
                          edit_message!: 2,
                          edit_message!: 3,
                          execute_github_webhook!: 3,
                          execute_github_webhook!: 4,
                          execute_github_webhook!: 5,
                          execute_slack_webhook!: 2,
                          execute_slack_webhook!: 3,
                          execute_slack_webhook!: 4,
                          execute_webhook!: 2,
                          execute_webhook!: 3,
                          execute_webhook!: 4,
                          gateway!: 0,
                          gateway_bot!: 0,
                          get_audit_logs!: 2,
                          get_channel!: 1,
                          get_channel_invites!: 1,
                          get_current_user!: 0,
                          get_current_user_guilds!: 1,
                          get_guild!: 1,
                          get_guild_ban!: 2,
                          get_guild_bans!: 1,
                          get_guild_channels!: 1,
                          get_guild_embed!: 1,
                          get_guild_emoji!: 2,
                          get_guild_integrations!: 1,
                          get_guild_invites!: 1,
                          get_guild_member!: 2,
                          get_guild_prune_count!: 2,
                          get_guild_roles!: 1,
                          get_guild_vanity_invite!: 1,
                          get_guild_vanity_url!: 1,
                          get_guild_voice_regions!: 1,
                          get_invite!: 1,
                          get_message!: 2,
                          get_messages!: 2,
                          get_pinned_messages!: 1,
                          get_reactions!: 3,
                          get_reactions!: 4,
                          get_user!: 1,
                          get_webhook!: 2,
                          leave_guild!: 1,
                          list_channel_webhooks!: 1,
                          list_guild_emojis!: 1,
                          list_guild_members!: 2,
                          list_guild_webhooks!: 1,
                          modify_channel!: 2,
                          modify_current_user!: 1,
                          modify_current_users_nick!: 3,
                          modify_guild!: 2,
                          modify_guild_channel_positions!: 2,
                          modify_guild_embed!: 2,
                          modify_guild_emoji!: 3,
                          modify_guild_integration!: 3,
                          modify_guild_member!: 3,
                          modify_guild_role!: 3,
                          modify_guild_role_positions!: 2,
                          remove_guild_ban!: 3,
                          remove_guild_member_role!: 4,
                          sync_guild_integration!: 2,
                          trigger_typing!: 1,
                          update_webhook!: 3
    end
  end

  defmacro __using__(:functions) do
    quote location: :keep do
      # I can't make the dialyzer happy about either of those :(
      @dialyzer {:nowarn_function, execute_github_webhook: 4}
      @dialyzer {:nowarn_function, execute_github_webhook!: 4}
      @dialyzer {:nowarn_function, execute_slack_webhook: 3}
      @dialyzer {:nowarn_function, execute_slack_webhook!: 3}
      @dialyzer {:nowarn_function, execute_webhook: 3}
      @dialyzer {:nowarn_function, execute_webhook!: 3}

      require Version
      @doc "See `c:Crux.Rest.add_guild_member/3`"

      @spec add_guild_member(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              data :: Crux.Rest.add_guild_member_data()
            ) :: {:ok, Crux.Structs.Member.t()} | {:error, term()}

      def add_guild_member(guild, user, data) do
        Crux.Rest.Functions.add_guild_member(guild, user, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.add_guild_member/3`, but raises an exception if it fails."

      @spec add_guild_member!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              data :: Crux.Rest.add_guild_member_data()
            ) :: Crux.Structs.Member.t() | no_return()

      def add_guild_member!(guild, user, data) do
        Crux.Rest.Functions.add_guild_member(guild, user, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.add_guild_member_role/4`"

      @spec add_guild_member_role(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def add_guild_member_role(guild, user, role, reason \\ nil) do
        Crux.Rest.Functions.add_guild_member_role(guild, user, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.add_guild_member_role/4`, but raises an exception if it fails."

      @spec add_guild_member_role!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def add_guild_member_role!(guild, user, role, reason \\ nil) do
        Crux.Rest.Functions.add_guild_member_role(guild, user, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.add_pinned_message/1`"

      @spec add_pinned_message(message :: Crux.Structs.Message.t()) :: :ok | {:error, term()}

      def add_pinned_message(map) do
        Crux.Rest.Functions.add_pinned_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.add_pinned_message/1`, but raises an exception if it fails."

      @spec add_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      def add_pinned_message!(map) do
        Crux.Rest.Functions.add_pinned_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.add_pinned_message/2`"

      @spec add_pinned_message(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | {:error, term()}

      def add_pinned_message(channel, message) do
        Crux.Rest.Functions.add_pinned_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.add_pinned_message/2`, but raises an exception if it fails."

      @spec add_pinned_message!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | no_return()

      def add_pinned_message!(channel, message) do
        Crux.Rest.Functions.add_pinned_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.begin_guild_prune/2`"

      @spec begin_guild_prune(
              guild :: Crux.Structs.Guild.id_resolvable(),
              opts :: Crux.Rest.begin_guild_prune_opts()
            ) :: {:ok, non_neg_integer()} | {:error, term()}

      def begin_guild_prune(guild, data) do
        Crux.Rest.Functions.begin_guild_prune(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.begin_guild_prune/2`, but raises an exception if it fails."

      @spec begin_guild_prune!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              opts :: Crux.Rest.begin_guild_prune_opts()
            ) :: non_neg_integer() | no_return()

      def begin_guild_prune!(guild, data) do
        Crux.Rest.Functions.begin_guild_prune(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_channel_invite/2`"

      @spec create_channel_invite(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.create_channel_invite_data()
            ) :: {:ok, Crux.Structs.Invite.t()} | {:error, term()}

      def create_channel_invite(channel, data) do
        Crux.Rest.Functions.create_channel_invite(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_channel_invite/2`, but raises an exception if it fails."

      @spec create_channel_invite!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.create_channel_invite_data()
            ) :: Crux.Structs.Invite.t() | no_return()

      def create_channel_invite!(channel, data) do
        Crux.Rest.Functions.create_channel_invite(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_dm/1`"

      @spec create_dm(user :: Crux.Structs.User.id_resolvable()) ::
              {:ok, Crux.Structs.Channel.t()} | {:error, term()}

      def create_dm(user) do
        Crux.Rest.Functions.create_dm(user)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_dm/1`, but raises an exception if it fails."

      @spec create_dm!(user :: Crux.Structs.User.id_resolvable()) ::
              Crux.Structs.Channel.t() | no_return()

      def create_dm!(user) do
        Crux.Rest.Functions.create_dm(user)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild/1`"

      @spec create_guild(term()) :: {:ok, Crux.Structs.Guild.t()} | {:error, term()}

      def create_guild(data) do
        Crux.Rest.Functions.create_guild(data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild/1`, but raises an exception if it fails."

      @spec create_guild!(term()) :: Crux.Structs.Guild.t() | no_return()

      def create_guild!(data) do
        Crux.Rest.Functions.create_guild(data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild_ban/3`"

      @spec create_guild_ban(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def create_guild_ban(guild, user, reason \\ nil) do
        Crux.Rest.Functions.create_guild_ban(guild, user, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild_ban/3`, but raises an exception if it fails."

      @spec create_guild_ban!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def create_guild_ban!(guild, user, reason \\ nil) do
        Crux.Rest.Functions.create_guild_ban(guild, user, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild_channel/2`"

      @spec create_guild_channel(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_channel_data()
            ) :: {:ok, Crux.Structs.Channel.t()} | {:error, term()}

      def create_guild_channel(guild, data) do
        Crux.Rest.Functions.create_guild_channel(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild_channel/2`, but raises an exception if it fails."

      @spec create_guild_channel!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_channel_data()
            ) :: Crux.Structs.Channel.t() | no_return()

      def create_guild_channel!(guild, data) do
        Crux.Rest.Functions.create_guild_channel(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild_emoji/2`"

      @spec create_guild_emoji(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_emoji_data()
            ) :: {:ok, Crux.Structs.Emoji} | {:error, term()}

      def create_guild_emoji(guild, data) do
        Crux.Rest.Functions.create_guild_emoji(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild_emoji/2`, but raises an exception if it fails."

      @spec create_guild_emoji!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.create_guild_emoji_data()
            ) :: Crux.Structs.Emoji | no_return()

      def create_guild_emoji!(guild, data) do
        Crux.Rest.Functions.create_guild_emoji(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild_integration/2`"

      @spec create_guild_integration(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data ::
                %{
                  required(:type) => String.t(),
                  required(:id) => Crux.Structs.Snowflake.resolvable()
                }
                | [{:type, String.t()} | {:id, Crux.Structs.Snowflake.resolvable()}]
            ) :: :ok | {:error, term()}

      def create_guild_integration(guild, data) do
        Crux.Rest.Functions.create_guild_integration(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild_integration/2`, but raises an exception if it fails."

      @spec create_guild_integration!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data ::
                %{
                  required(:type) => String.t(),
                  required(:id) => Crux.Structs.Snowflake.resolvable()
                }
                | [{:type, String.t()} | {:id, Crux.Structs.Snowflake.resolvable()}]
            ) :: :ok | no_return()

      def create_guild_integration!(guild, data) do
        Crux.Rest.Functions.create_guild_integration(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_guild_role/2`"

      @spec create_guild_role(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: {:ok, Crux.Structs.Role.t()} | {:error, term()}

      def create_guild_role(guild, data) do
        Crux.Rest.Functions.create_guild_role(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_guild_role/2`, but raises an exception if it fails."

      @spec create_guild_role!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: Crux.Structs.Role.t() | no_return()

      def create_guild_role!(guild, data) do
        Crux.Rest.Functions.create_guild_role(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_message/2`"

      @spec create_message(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.create_message_data()
            ) :: {:ok, Crux.Structs.Message.t()} | {:error, term()}

      def create_message(channel_or_message, data) do
        Crux.Rest.Functions.create_message(channel_or_message, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_message/2`, but raises an exception if it fails."

      @spec create_message!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.create_message_data()
            ) :: Crux.Structs.Message.t() | no_return()

      def create_message!(channel_or_message, data) do
        Crux.Rest.Functions.create_message(channel_or_message, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_reaction/2`"

      @spec create_reaction(
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

      def create_reaction(map, emoji) do
        Crux.Rest.Functions.create_reaction(map, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_reaction/2`, but raises an exception if it fails."

      @spec create_reaction!(
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | no_return()

      def create_reaction!(map, emoji) do
        Crux.Rest.Functions.create_reaction(map, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.create_reaction/3`"

      @spec create_reaction(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable()
            ) :: :ok | {:error, term()}

      def create_reaction(channel, message, emoji) do
        Crux.Rest.Functions.create_reaction(channel, message, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.create_reaction/3`, but raises an exception if it fails."

      @spec create_reaction!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable()
            ) :: :ok | no_return()

      def create_reaction!(channel, message, emoji) do
        Crux.Rest.Functions.create_reaction(channel, message, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_all_reactions/2`"

      @spec delete_all_reactions(
              message :: Crux.Structs.Message.t(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

      def delete_all_reactions(map, emoji) do
        Crux.Rest.Functions.delete_all_reactions(map, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_all_reactions/2`, but raises an exception if it fails."

      @spec delete_all_reactions!(
              message :: Crux.Structs.Message.t(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | no_return()

      def delete_all_reactions!(map, emoji) do
        Crux.Rest.Functions.delete_all_reactions(map, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_all_reactions/3`"

      @spec delete_all_reactions(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | {:error, term()}

      def delete_all_reactions(channel, message, emoji) do
        Crux.Rest.Functions.delete_all_reactions(channel, message, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_all_reactions/3`, but raises an exception if it fails."

      @spec delete_all_reactions!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable()
            ) :: :ok | no_return()

      def delete_all_reactions!(channel, message, emoji) do
        Crux.Rest.Functions.delete_all_reactions(channel, message, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_channel/2`"

      @spec delete_channel(
              channel :: Crux.Structs.Channel.id_resolvable(),
              reason :: String.t() | nil
            ) :: {:ok, Crux.Structs.Channel.t()} | {:error, term()}

      def delete_channel(channel, reason \\ nil) do
        Crux.Rest.Functions.delete_channel(channel, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_channel/2`, but raises an exception if it fails."

      @spec delete_channel!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              reason :: String.t() | nil
            ) :: Crux.Structs.Channel.t() | no_return()

      def delete_channel!(channel, reason \\ nil) do
        Crux.Rest.Functions.delete_channel(channel, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_channel_permissions/3`"

      @spec delete_channel_permissions(
              channel :: Crux.Structs.Channel.id_resolvable(),
              target :: Crux.Structs.Overwrite.target_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def delete_channel_permissions(channel, target, reason \\ nil) do
        Crux.Rest.Functions.delete_channel_permissions(channel, target, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_channel_permissions/3`, but raises an exception if it fails."

      @spec delete_channel_permissions!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              target :: Crux.Structs.Overwrite.target_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def delete_channel_permissions!(channel, target, reason \\ nil) do
        Crux.Rest.Functions.delete_channel_permissions(channel, target, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_guild/1`"

      @spec delete_guild(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | {:error, term()}

      def delete_guild(guild) do
        Crux.Rest.Functions.delete_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_guild/1`, but raises an exception if it fails."

      @spec delete_guild!(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | no_return()

      def delete_guild!(guild) do
        Crux.Rest.Functions.delete_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_guild_emoji/3`"

      @spec delete_guild_emoji(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def delete_guild_emoji(guild, emoji, reason \\ nil) do
        Crux.Rest.Functions.delete_guild_emoji(guild, emoji, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_guild_emoji/3`, but raises an exception if it fails."

      @spec delete_guild_emoji!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def delete_guild_emoji!(guild, emoji, reason \\ nil) do
        Crux.Rest.Functions.delete_guild_emoji(guild, emoji, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_guild_integration/2`"

      @spec delete_guild_integration(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable()
            ) :: :ok | {:error, term()}

      def delete_guild_integration(guild, integration) do
        Crux.Rest.Functions.delete_guild_integration(guild, integration)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_guild_integration/2`, but raises an exception if it fails."

      @spec delete_guild_integration!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable()
            ) :: :ok | no_return()

      def delete_guild_integration!(guild, integration) do
        Crux.Rest.Functions.delete_guild_integration(guild, integration)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_guild_role/3`"

      @spec delete_guild_role(
              guild :: Crux.Structs.Guild.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def delete_guild_role(guild, role, reason \\ nil) do
        Crux.Rest.Functions.delete_guild_role(guild, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_guild_role/3`, but raises an exception if it fails."

      @spec delete_guild_role!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def delete_guild_role!(guild, role, reason \\ nil) do
        Crux.Rest.Functions.delete_guild_role(guild, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_invite/1`"

      @spec delete_invite(invite_or_code :: String.t() | Crux.Structs.Invite.t()) ::
              {:ok, Crux.Structs.Invite.t()} | {:error, term()}

      def delete_invite(code) do
        Crux.Rest.Functions.delete_invite(code)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_invite/1`, but raises an exception if it fails."

      @spec delete_invite!(invite_or_code :: String.t() | Crux.Structs.Invite.t()) ::
              Crux.Structs.Invite.t() | no_return()

      def delete_invite!(code) do
        Crux.Rest.Functions.delete_invite(code)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_message/1`"

      @spec delete_message(message :: Crux.Structs.Message.t()) :: :ok | {:error, term()}

      def delete_message(map) do
        Crux.Rest.Functions.delete_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_message/1`, but raises an exception if it fails."

      @spec delete_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      def delete_message!(map) do
        Crux.Rest.Functions.delete_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_message/2`"

      @spec delete_message(
              channel_id :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | {:error, term()}

      def delete_message(channel, message) do
        Crux.Rest.Functions.delete_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_message/2`, but raises an exception if it fails."

      @spec delete_message!(
              channel_id :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | no_return()

      def delete_message!(channel, message) do
        Crux.Rest.Functions.delete_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_messages/2`"

      @spec delete_messages(
              channel :: Crux.Structs.Channel.id_resolvable(),
              messages :: [Crux.Structs.Message.id_resolvable()]
            ) :: :ok | {:error, term()}

      def delete_messages(channel, messages) do
        Crux.Rest.Functions.delete_messages(channel, messages)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_messages/2`, but raises an exception if it fails."

      @spec delete_messages!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              messages :: [Crux.Structs.Message.id_resolvable()]
            ) :: :ok | no_return()

      def delete_messages!(channel, messages) do
        Crux.Rest.Functions.delete_messages(channel, messages)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_pinned_message/1`"

      @spec delete_pinned_message(message :: Crux.Structs.Message.t()) :: :ok | {:error, term()}

      def delete_pinned_message(map) do
        Crux.Rest.Functions.delete_pinned_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_pinned_message/1`, but raises an exception if it fails."

      @spec delete_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()

      def delete_pinned_message!(map) do
        Crux.Rest.Functions.delete_pinned_message(map)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_pinned_message/2`"

      @spec delete_pinned_message(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | {:error, term()}

      def delete_pinned_message(channel, message) do
        Crux.Rest.Functions.delete_pinned_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_pinned_message/2`, but raises an exception if it fails."

      @spec delete_pinned_message!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable()
            ) :: :ok | no_return()

      def delete_pinned_message!(channel, message) do
        Crux.Rest.Functions.delete_pinned_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_reaction/4`"

      @spec delete_reaction(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) :: :ok | {:error, term()}

      def delete_reaction(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user \\ "@me",
            mayber_user \\ "@me"
          ) do
        Crux.Rest.Functions.delete_reaction(
          message_or_channel,
          emoji_or_message_id,
          emoji_or_maybe_user,
          mayber_user
        )
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_reaction/4`, but raises an exception if it fails."

      @spec delete_reaction!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) :: :ok | no_return()

      def delete_reaction!(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user \\ "@me",
            mayber_user \\ "@me"
          ) do
        Crux.Rest.Functions.delete_reaction(
          message_or_channel,
          emoji_or_message_id,
          emoji_or_maybe_user,
          mayber_user
        )
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.delete_webhook/2`"

      @spec delete_webhook(user :: Crux.Structs.User.id_resolvable(), token :: String.t() | nil) ::
              :ok | {:error, term()}

      def delete_webhook(user, token \\ nil) do
        Crux.Rest.Functions.delete_webhook(user, token)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.delete_webhook/2`, but raises an exception if it fails."

      @spec delete_webhook!(user :: Crux.Structs.User.id_resolvable(), token :: String.t() | nil) ::
              :ok | no_return()

      def delete_webhook!(user, token \\ nil) do
        Crux.Rest.Functions.delete_webhook(user, token)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.edit_channel_permissions/3`"

      @spec edit_channel_permissions(
              channel :: Crux.Structs.Channel.id_resolvable(),
              target :: Crux.Structs.Overwrite.target_resolvable(),
              data :: Crux.Rest.edit_channel_permissions_data()
            ) :: :ok | {:error, :missing_target} | {:error, term()}

      def edit_channel_permissions(channel, target, data) do
        Crux.Rest.Functions.edit_channel_permissions(channel, target, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.edit_channel_permissions/3`, but raises an exception if it fails."

      @spec edit_channel_permissions!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              target :: Crux.Structs.Overwrite.target_resolvable(),
              data :: Crux.Rest.edit_channel_permissions_data()
            ) :: :ok | no_return()

      def edit_channel_permissions!(channel, target, data) do
        Crux.Rest.Functions.edit_channel_permissions(channel, target, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.edit_message/2`"

      @spec edit_message(
              target :: Crux.Structs.Message.t(),
              args :: Crux.Rest.message_edit_data()
            ) :: {:ok, Crux.Structs.Message.t()} | {:error, term()}

      def edit_message(map, data) do
        Crux.Rest.Functions.edit_message(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.edit_message/2`, but raises an exception if it fails."

      @spec edit_message!(
              target :: Crux.Structs.Message.t(),
              args :: Crux.Rest.message_edit_data()
            ) :: Crux.Structs.Message.t() | no_return()

      def edit_message!(map, data) do
        Crux.Rest.Functions.edit_message(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.edit_message/3`"

      @spec edit_message(
              channel_id :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable(),
              args :: Crux.Rest.message_edit_data()
            ) :: {:ok, Crux.Structs.Message.t()} | {:error, term()}

      def edit_message(channel, message, data) do
        Crux.Rest.Functions.edit_message(channel, message, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.edit_message/3`, but raises an exception if it fails."

      @spec edit_message!(
              channel_id :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable(),
              args :: Crux.Rest.message_edit_data()
            ) :: Crux.Structs.Message.t() | no_return()

      def edit_message!(channel, message, data) do
        Crux.Rest.Functions.edit_message(channel, message, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_github_webhook/3`"

      @spec execute_github_webhook(
              webhook :: Crux.Structs.Webhook.t(),
              event :: String.t(),
              data :: term()
            ) :: :ok

      def execute_github_webhook(map, event, data) do
        Crux.Rest.Functions.execute_github_webhook(map, event, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_github_webhook/3`, but raises an exception if it fails."

      @spec execute_github_webhook!(
              webhook :: Crux.Structs.Webhook.t(),
              event :: String.t(),
              data :: term()
            ) :: :ok | no_return()

      def execute_github_webhook!(map, event, data) do
        Crux.Rest.Functions.execute_github_webhook(map, event, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_github_webhook/5`"

      @spec execute_github_webhook(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              event :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term()}

      def execute_github_webhook(user, token, event, wait \\ false, data) do
        Crux.Rest.Functions.execute_github_webhook(user, token, event, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_github_webhook/5`, but raises an exception if it fails."

      @spec execute_github_webhook!(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              event :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | no_return()

      def execute_github_webhook!(user, token, event, wait \\ false, data) do
        Crux.Rest.Functions.execute_github_webhook(user, token, event, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_slack_webhook/2`"

      @spec execute_slack_webhook(webhook :: Crux.Structs.Webhook.t(), data :: term()) :: :ok

      def execute_slack_webhook(map, data) do
        Crux.Rest.Functions.execute_slack_webhook(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_slack_webhook/2`, but raises an exception if it fails."

      @spec execute_slack_webhook!(webhook :: Crux.Structs.Webhook.t(), data :: term()) ::
              :ok | no_return()

      def execute_slack_webhook!(map, data) do
        Crux.Rest.Functions.execute_slack_webhook(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_slack_webhook/4`"

      @spec execute_slack_webhook(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | {:error, term()}

      def execute_slack_webhook(user, token, wait \\ false, data) do
        Crux.Rest.Functions.execute_slack_webhook(user, token, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_slack_webhook/4`, but raises an exception if it fails."

      @spec execute_slack_webhook!(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | no_return()

      def execute_slack_webhook!(user, token, wait \\ false, data) do
        Crux.Rest.Functions.execute_slack_webhook(user, token, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_webhook/2`"

      @spec execute_webhook(
              webhook :: Crux.Structs.Webhook.t(),
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok

      def execute_webhook(map, data) do
        Crux.Rest.Functions.execute_webhook(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_webhook/2`, but raises an exception if it fails."

      @spec execute_webhook!(
              webhook :: Crux.Structs.Webhook.t(),
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok | no_return()

      def execute_webhook!(map, data) do
        Crux.Rest.Functions.execute_webhook(map, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.execute_webhook/4`"

      @spec execute_webhook(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok | {:ok, Crux.Structs.Message.t()} | {:error, term()}

      def execute_webhook(user, token, wait \\ false, data) do
        Crux.Rest.Functions.execute_webhook(user, token, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.execute_webhook/4`, but raises an exception if it fails."

      @spec execute_webhook!(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: Crux.Rest.execute_webhook_options()
            ) :: :ok | no_return()

      def execute_webhook!(user, token, wait \\ false, data) do
        Crux.Rest.Functions.execute_webhook(user, token, wait, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.gateway/0`"

      @spec gateway() :: {:ok, term()} | {:error, term()}

      def gateway() do
        Crux.Rest.Functions.gateway()
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.gateway/0`, but raises an exception if it fails."

      @spec gateway!() :: term() | no_return()

      def gateway!() do
        Crux.Rest.Functions.gateway()
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.gateway_bot/0`"

      @spec gateway_bot() :: {:ok, term()} | {:error, term()}

      def gateway_bot() do
        Crux.Rest.Functions.gateway_bot()
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.gateway_bot/0`, but raises an exception if it fails."

      @spec gateway_bot!() :: term() | no_return()

      def gateway_bot!() do
        Crux.Rest.Functions.gateway_bot()
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_audit_logs/2`"

      @spec get_audit_logs(
              guild :: Crux.Structs.Guild.id_resolvable(),
              options :: Crux.Rest.audit_log_options() | nil
            ) :: {:ok, Crux.Structs.AuditLog.t()} | {:error, term()}

      def get_audit_logs(guild, data \\ []) do
        Crux.Rest.Functions.get_audit_logs(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_audit_logs/2`, but raises an exception if it fails."

      @spec get_audit_logs!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              options :: Crux.Rest.audit_log_options() | nil
            ) :: Crux.Structs.AuditLog.t() | no_return()

      def get_audit_logs!(guild, data \\ []) do
        Crux.Rest.Functions.get_audit_logs(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_channel/1`"

      @spec get_channel(channel :: Crux.Structs.Channel.id_resolvable()) ::
              {:ok, Crux.Structs.Channel.t()} | {:error, term()}

      def get_channel(channel) do
        Crux.Rest.Functions.get_channel(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_channel/1`, but raises an exception if it fails."

      @spec get_channel!(channel :: Crux.Structs.Channel.id_resolvable()) ::
              Crux.Structs.Channel.t() | no_return()

      def get_channel!(channel) do
        Crux.Rest.Functions.get_channel(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_channel_invites/1`"

      @spec get_channel_invites(channel :: Crux.Structs.Channel.id_resolvable()) ::
              {:ok, %{required(String.t()) => Crux.Structs.Invite.t()}} | {:error, term()}

      def get_channel_invites(channel) do
        Crux.Rest.Functions.get_channel_invites(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_channel_invites/1`, but raises an exception if it fails."

      @spec get_channel_invites!(channel :: Crux.Structs.Channel.id_resolvable()) ::
              %{required(String.t()) => Crux.Structs.Invite.t()} | no_return()

      def get_channel_invites!(channel) do
        Crux.Rest.Functions.get_channel_invites(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_current_user/0`"

      @spec get_current_user() :: {:ok, Crux.Structs.User.t()} | {:error, term()}

      def get_current_user() do
        Crux.Rest.Functions.get_current_user()
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_current_user/0`, but raises an exception if it fails."

      @spec get_current_user!() :: Crux.Structs.User.t() | no_return()

      def get_current_user!() do
        Crux.Rest.Functions.get_current_user()
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_current_user_guilds/1`"

      @spec get_current_user_guilds(data :: Crux.Rest.get_current_user_guild_data()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Guild.t()}}
              | {:error, term()}

      def get_current_user_guilds(data \\ []) do
        Crux.Rest.Functions.get_current_user_guilds(data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_current_user_guilds/1`, but raises an exception if it fails."

      @spec get_current_user_guilds!(data :: Crux.Rest.get_current_user_guild_data()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Guild.t()} | no_return()

      def get_current_user_guilds!(data \\ []) do
        Crux.Rest.Functions.get_current_user_guilds(data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild/1`"

      @spec get_guild(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, Crux.Structs.Guild.t()} | {:error, term()}

      def get_guild(guild) do
        Crux.Rest.Functions.get_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild/1`, but raises an exception if it fails."

      @spec get_guild!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              Crux.Structs.Guild.t() | no_return()

      def get_guild!(guild) do
        Crux.Rest.Functions.get_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_ban/2`"

      @spec get_guild_ban(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) ::
              {:ok,
               %{required(:user) => Crux.Structs.User.t(), required(:reason) => String.t() | nil}}
              | {:error, term()}

      def get_guild_ban(guild, user) do
        Crux.Rest.Functions.get_guild_ban(guild, user)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_ban/2`, but raises an exception if it fails."

      @spec get_guild_ban!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) ::
              %{required(:user) => Crux.Structs.User.t(), required(:reason) => String.t() | nil}
              | no_return()

      def get_guild_ban!(guild, user) do
        Crux.Rest.Functions.get_guild_ban(guild, user)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_bans/1`"

      @spec get_guild_bans(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok,
               %{
                 required(Crux.Structs.Snowflake.t()) => %{
                   required(:user) => Crux.Structs.User.t(),
                   required(:reason) => String.t() | nil
                 }
               }}
              | {:error, term()}

      def get_guild_bans(guild) do
        Crux.Rest.Functions.get_guild_bans(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_bans/1`, but raises an exception if it fails."

      @spec get_guild_bans!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{
                required(Crux.Structs.Snowflake.t()) => %{
                  required(:user) => Crux.Structs.User.t(),
                  required(:reason) => String.t() | nil
                }
              }
              | no_return()

      def get_guild_bans!(guild) do
        Crux.Rest.Functions.get_guild_bans(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_channels/1`"

      @spec get_guild_channels(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Channel.t()}}
              | {:error, term()}

      def get_guild_channels(guild) do
        Crux.Rest.Functions.get_guild_channels(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_channels/1`, but raises an exception if it fails."

      @spec get_guild_channels!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Channel.t()} | no_return()

      def get_guild_channels!(guild) do
        Crux.Rest.Functions.get_guild_channels(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_embed/1`"

      @spec get_guild_embed(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, term()} | {:error, term()}

      def get_guild_embed(guild) do
        Crux.Rest.Functions.get_guild_embed(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_embed/1`, but raises an exception if it fails."

      @spec get_guild_embed!(guild :: Crux.Structs.Guild.id_resolvable()) :: term() | no_return()

      def get_guild_embed!(guild) do
        Crux.Rest.Functions.get_guild_embed(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_emoji/2`"

      @spec get_guild_emoji(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable()
            ) :: {:ok, Crux.Structs.Emoji} | {:error, term()}

      def get_guild_emoji(guild, emoji) do
        Crux.Rest.Functions.get_guild_emoji(guild, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_emoji/2`, but raises an exception if it fails."

      @spec get_guild_emoji!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable()
            ) :: Crux.Structs.Emoji | no_return()

      def get_guild_emoji!(guild, emoji) do
        Crux.Rest.Functions.get_guild_emoji(guild, emoji)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_integrations/1`"

      @spec get_guild_integrations(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, list()} | {:error, term()}

      def get_guild_integrations(guild) do
        Crux.Rest.Functions.get_guild_integrations(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_integrations/1`, but raises an exception if it fails."

      @spec get_guild_integrations!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              list() | no_return()

      def get_guild_integrations!(guild) do
        Crux.Rest.Functions.get_guild_integrations(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_invites/1`"

      @spec get_guild_invites(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, %{required(String.t()) => Crux.Structs.Invite.t()}} | {:error, term()}

      def get_guild_invites(guild) do
        Crux.Rest.Functions.get_guild_invites(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_invites/1`, but raises an exception if it fails."

      @spec get_guild_invites!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{required(String.t()) => Crux.Structs.Invite.t()} | no_return()

      def get_guild_invites!(guild) do
        Crux.Rest.Functions.get_guild_invites(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_member/2`"

      @spec get_guild_member(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) :: {:ok, Crux.Structs.Member.t()} | {:error, term()}

      def get_guild_member(guild, user) do
        Crux.Rest.Functions.get_guild_member(guild, user)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_member/2`, but raises an exception if it fails."

      @spec get_guild_member!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable()
            ) :: Crux.Structs.Member.t() | no_return()

      def get_guild_member!(guild, user) do
        Crux.Rest.Functions.get_guild_member(guild, user)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_prune_count/2`"

      @spec get_guild_prune_count(
              guild :: Crux.Structs.Guild.id_resolvable(),
              days :: pos_integer()
            ) :: {:ok, non_neg_integer()} | {:error, term()}

      def get_guild_prune_count(guild, days) do
        Crux.Rest.Functions.get_guild_prune_count(guild, days)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_prune_count/2`, but raises an exception if it fails."

      @spec get_guild_prune_count!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              days :: pos_integer()
            ) :: non_neg_integer() | no_return()

      def get_guild_prune_count!(guild, days) do
        Crux.Rest.Functions.get_guild_prune_count(guild, days)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_roles/1`"

      @spec get_guild_roles(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()}}
              | {:error, term()}

      def get_guild_roles(guild) do
        Crux.Rest.Functions.get_guild_roles(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_roles/1`, but raises an exception if it fails."

      @spec get_guild_roles!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()} | no_return()

      def get_guild_roles!(guild) do
        Crux.Rest.Functions.get_guild_roles(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_vanity_invite/1`"

      @spec get_guild_vanity_invite(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, Crux.Structs.Invite.t()} | {:error, term()}

      def get_guild_vanity_invite(guild) do
        Crux.Rest.Functions.get_guild_vanity_invite(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_vanity_invite/1`, but raises an exception if it fails."

      @spec get_guild_vanity_invite!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              Crux.Structs.Invite.t() | no_return()

      def get_guild_vanity_invite!(guild) do
        Crux.Rest.Functions.get_guild_vanity_invite(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_vanity_url/1`"

      @spec get_guild_vanity_url(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, String.t()} | {:error, term()}
      Version.deprecated("Use get_guild_vanity_invite/1 instead")

      def get_guild_vanity_url(guild) do
        Crux.Rest.Functions.get_guild_vanity_url(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_vanity_url/1`, but raises an exception if it fails."

      @spec get_guild_vanity_url!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              String.t() | no_return()
      Version.deprecated("Use get_guild_vanity_invite/1 instead")

      def get_guild_vanity_url!(guild) do
        Crux.Rest.Functions.get_guild_vanity_url(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_guild_voice_regions/1`"

      @spec get_guild_voice_regions(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, term()} | {:error, term()}

      def get_guild_voice_regions(guild) do
        Crux.Rest.Functions.get_guild_voice_regions(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_guild_voice_regions/1`, but raises an exception if it fails."

      @spec get_guild_voice_regions!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              term() | no_return()

      def get_guild_voice_regions!(guild) do
        Crux.Rest.Functions.get_guild_voice_regions(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_invite/1`"

      @spec get_invite(code :: String.t()) :: {:ok, Crux.Structs.Invite.t()} | {:error, term()}

      def get_invite(code) do
        Crux.Rest.Functions.get_invite(code)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_invite/1`, but raises an exception if it fails."

      @spec get_invite!(code :: String.t()) :: Crux.Structs.Invite.t() | no_return()

      def get_invite!(code) do
        Crux.Rest.Functions.get_invite(code)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_message/2`"

      @spec get_message(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable()
            ) :: {:ok, Crux.Structs.Message.t()} | {:error, term()}

      def get_message(channel, message) do
        Crux.Rest.Functions.get_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_message/2`, but raises an exception if it fails."

      @spec get_message!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message_id :: Crux.Structs.Message.id_resolvable()
            ) :: Crux.Structs.Message.t() | no_return()

      def get_message!(channel, message) do
        Crux.Rest.Functions.get_message(channel, message)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_messages/2`"

      @spec get_messages(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.get_messages_data()
            ) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()}}
              | {:error, term()}

      def get_messages(channel, data) do
        Crux.Rest.Functions.get_messages(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_messages/2`, but raises an exception if it fails."

      @spec get_messages!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              args :: Crux.Rest.get_messages_data()
            ) :: %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()} | no_return()

      def get_messages!(channel, data) do
        Crux.Rest.Functions.get_messages(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_pinned_messages/1`"

      @spec get_pinned_messages(channel :: Crux.Structs.Channel.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()}}
              | {:error, term()}

      def get_pinned_messages(channel) do
        Crux.Rest.Functions.get_pinned_messages(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_pinned_messages/1`, but raises an exception if it fails."

      @spec get_pinned_messages!(channel :: Crux.Structs.Channel.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Message.t()} | no_return()

      def get_pinned_messages!(channel) do
        Crux.Rest.Functions.get_pinned_messages(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_reactions/4`"

      @spec get_reactions(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable() | list(),
              args :: Crux.Rest.get_reactions_data()
            ) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.User.t()}}
              | {:error, term()}

      def get_reactions(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data \\ [],
            maybe_data \\ []
          ) do
        Crux.Rest.Functions.get_reactions(
          channel_or_message,
          emoji_or_message_id,
          emoji_or_maybe_data,
          maybe_data
        )
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_reactions/4`, but raises an exception if it fails."

      @spec get_reactions!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              message :: Crux.Structs.Message.id_resolvable(),
              emoji :: Crux.Structs.Emoji.identifier_resolvable() | list(),
              args :: Crux.Rest.get_reactions_data()
            ) :: %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.User.t()} | no_return()

      def get_reactions!(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data \\ [],
            maybe_data \\ []
          ) do
        Crux.Rest.Functions.get_reactions(
          channel_or_message,
          emoji_or_message_id,
          emoji_or_maybe_data,
          maybe_data
        )
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_user/1`"

      @spec get_user(user :: Crux.Structs.User.id_resolvable()) ::
              {:ok, Crux.Structs.User.t()} | {:error, term()}

      def get_user(user) do
        Crux.Rest.Functions.get_user(user)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_user/1`, but raises an exception if it fails."

      @spec get_user!(user :: Crux.Structs.User.id_resolvable()) ::
              Crux.Structs.User.t() | no_return()

      def get_user!(user) do
        Crux.Rest.Functions.get_user(user)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.get_webhook/2`"

      @spec get_webhook(user :: Crux.Structs.User.id_resolvable(), token :: String.t() | nil) ::
              {:ok, Crux.Structs.Webhook.t()} | {:error, term()}

      def get_webhook(user, token \\ nil) do
        Crux.Rest.Functions.get_webhook(user, token)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.get_webhook/2`, but raises an exception if it fails."

      @spec get_webhook!(user :: Crux.Structs.User.id_resolvable(), token :: String.t() | nil) ::
              Crux.Structs.Webhook.t() | no_return()

      def get_webhook!(user, token \\ nil) do
        Crux.Rest.Functions.get_webhook(user, token)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.leave_guild/1`"

      @spec leave_guild(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | {:error, term()}

      def leave_guild(guild) do
        Crux.Rest.Functions.leave_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.leave_guild/1`, but raises an exception if it fails."

      @spec leave_guild!(guild :: Crux.Structs.Guild.id_resolvable()) :: :ok | no_return()

      def leave_guild!(guild) do
        Crux.Rest.Functions.leave_guild(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.list_channel_webhooks/1`"

      @spec list_channel_webhooks(channel :: Crux.Structs.Channel.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()}}
              | {:error, term()}

      def list_channel_webhooks(channel) do
        Crux.Rest.Functions.list_channel_webhooks(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.list_channel_webhooks/1`, but raises an exception if it fails."

      @spec list_channel_webhooks!(channel :: Crux.Structs.Channel.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()} | no_return()

      def list_channel_webhooks!(channel) do
        Crux.Rest.Functions.list_channel_webhooks(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.list_guild_emojis/1`"

      @spec list_guild_emojis(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Emoji.t()}}
              | {:error, term()}

      def list_guild_emojis(guild) do
        Crux.Rest.Functions.list_guild_emojis(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.list_guild_emojis/1`, but raises an exception if it fails."

      @spec list_guild_emojis!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Emoji.t()} | no_return()

      def list_guild_emojis!(guild) do
        Crux.Rest.Functions.list_guild_emojis(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.list_guild_members/2`"

      @spec list_guild_members(
              guild :: Crux.Structs.Guild.id_resolvable(),
              options :: Crux.Rest.list_guild_members_options()
            ) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Member.t()}}
              | {:error, term()}

      def list_guild_members(guild, options) do
        Crux.Rest.Functions.list_guild_members(guild, options)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.list_guild_members/2`, but raises an exception if it fails."

      @spec list_guild_members!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              options :: Crux.Rest.list_guild_members_options()
            ) :: %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Member.t()} | no_return()

      def list_guild_members!(guild, options) do
        Crux.Rest.Functions.list_guild_members(guild, options)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.list_guild_webhooks/1`"

      @spec list_guild_webhooks(guild :: Crux.Structs.Guild.id_resolvable()) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()}}
              | {:error, term()}

      def list_guild_webhooks(guild) do
        Crux.Rest.Functions.list_guild_webhooks(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.list_guild_webhooks/1`, but raises an exception if it fails."

      @spec list_guild_webhooks!(guild :: Crux.Structs.Guild.id_resolvable()) ::
              %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Webhook.t()} | no_return()

      def list_guild_webhooks!(guild) do
        Crux.Rest.Functions.list_guild_webhooks(guild)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_channel/2`"

      @spec modify_channel(
              channel :: Crux.Structs.Channel.id_resolvable(),
              data :: Crux.Rest.modify_channel_data()
            ) :: {:ok, Crux.Structs.Channel.t()} | {:error, term()}

      def modify_channel(channel, data) do
        Crux.Rest.Functions.modify_channel(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_channel/2`, but raises an exception if it fails."

      @spec modify_channel!(
              channel :: Crux.Structs.Channel.id_resolvable(),
              data :: Crux.Rest.modify_channel_data()
            ) :: Crux.Structs.Channel.t() | no_return()

      def modify_channel!(channel, data) do
        Crux.Rest.Functions.modify_channel(channel, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_current_user/1`"

      @spec modify_current_user(data :: Crux.Rest.modify_current_user_data()) ::
              {:ok, Crux.Structs.User.t()} | {:error, term()}

      def modify_current_user(data) do
        Crux.Rest.Functions.modify_current_user(data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_current_user/1`, but raises an exception if it fails."

      @spec modify_current_user!(data :: Crux.Rest.modify_current_user_data()) ::
              Crux.Structs.User.t() | no_return()

      def modify_current_user!(data) do
        Crux.Rest.Functions.modify_current_user(data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_current_users_nick/3`"

      @spec modify_current_users_nick(
              guild :: Crux.Structs.Guild.id_resolvable(),
              nick :: String.t(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def modify_current_users_nick(guild, nick, reason \\ nil) do
        Crux.Rest.Functions.modify_current_users_nick(guild, nick, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_current_users_nick/3`, but raises an exception if it fails."

      @spec modify_current_users_nick!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              nick :: String.t(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def modify_current_users_nick!(guild, nick, reason \\ nil) do
        Crux.Rest.Functions.modify_current_users_nick(guild, nick, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild/2`"

      @spec modify_guild(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.modify_guild_data()
            ) :: {:ok, Crux.Structs.Guild.t()} | {:error, term()}

      def modify_guild(guild, data) do
        Crux.Rest.Functions.modify_guild(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild/2`, but raises an exception if it fails."

      @spec modify_guild!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: Crux.Rest.modify_guild_data()
            ) :: Crux.Structs.Guild.t() | no_return()

      def modify_guild!(guild, data) do
        Crux.Rest.Functions.modify_guild(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_channel_positions/2`"

      @spec modify_guild_channel_positions(
              guild :: Crux.Structs.Guild.id_resolvable(),
              channels :: [Crux.Structs.Channel.position_resolvable()]
            ) :: :ok | {:error, term()}

      def modify_guild_channel_positions(guild, channels) do
        Crux.Rest.Functions.modify_guild_channel_positions(guild, channels)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_channel_positions/2`, but raises an exception if it fails."

      @spec modify_guild_channel_positions!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              channels :: [Crux.Structs.Channel.position_resolvable()]
            ) :: :ok | no_return()

      def modify_guild_channel_positions!(guild, channels) do
        Crux.Rest.Functions.modify_guild_channel_positions(guild, channels)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_embed/2`"

      @spec modify_guild_embed(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data ::
                %{
                  optional(:enabled) => boolean(),
                  optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                }
                | [{:enabled, boolean()} | {:channel_id, Crux.Structs.Channel.id_resolvable()}]
            ) :: {:ok, term()} | {:error, term()}

      def modify_guild_embed(guild, data) do
        Crux.Rest.Functions.modify_guild_embed(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_embed/2`, but raises an exception if it fails."

      @spec modify_guild_embed!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data ::
                %{
                  optional(:enabled) => boolean(),
                  optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                }
                | [{:enabled, boolean()} | {:channel_id, Crux.Structs.Channel.id_resolvable()}]
            ) :: term() | no_return()

      def modify_guild_embed!(guild, data) do
        Crux.Rest.Functions.modify_guild_embed(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_emoji/3`"

      @spec modify_guild_emoji(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable(),
              data :: Crux.Rest.modify_guild_emoji_data()
            ) :: {:ok, Crux.Structs.Emoji} | {:error, term()}

      def modify_guild_emoji(guild, emoji, data) do
        Crux.Rest.Functions.modify_guild_emoji(guild, emoji, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_emoji/3`, but raises an exception if it fails."

      @spec modify_guild_emoji!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              emoji :: Crux.Structs.Emoji.id_resolvable(),
              data :: Crux.Rest.modify_guild_emoji_data()
            ) :: Crux.Structs.Emoji | no_return()

      def modify_guild_emoji!(guild, emoji, data) do
        Crux.Rest.Functions.modify_guild_emoji(guild, emoji, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_integration/3`"

      @spec modify_guild_integration(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable(),
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

      def modify_guild_integration(guild, integration, data) do
        Crux.Rest.Functions.modify_guild_integration(guild, integration, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_integration/3`, but raises an exception if it fails."

      @spec modify_guild_integration!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable(),
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
            ) :: :ok | no_return()

      def modify_guild_integration!(guild, integration, data) do
        Crux.Rest.Functions.modify_guild_integration(guild, integration, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_member/3`"

      @spec modify_guild_member(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              data :: Crux.Rest.modify_guild_member_data()
            ) :: :ok | {:error, term()}

      def modify_guild_member(guild, user, data) do
        Crux.Rest.Functions.modify_guild_member(guild, user, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_member/3`, but raises an exception if it fails."

      @spec modify_guild_member!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              data :: Crux.Rest.modify_guild_member_data()
            ) :: :ok | no_return()

      def modify_guild_member!(guild, user, data) do
        Crux.Rest.Functions.modify_guild_member(guild, user, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_role/3`"

      @spec modify_guild_role(
              guild :: Crux.Structs.Guild.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: {:ok, Crux.Structs.Role.t()} | {:error, term()}

      def modify_guild_role(guild, role, data) do
        Crux.Rest.Functions.modify_guild_role(guild, role, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_role/3`, but raises an exception if it fails."

      @spec modify_guild_role!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              data :: Crux.Rest.guild_role_data()
            ) :: Crux.Structs.Role.t() | no_return()

      def modify_guild_role!(guild, role, data) do
        Crux.Rest.Functions.modify_guild_role(guild, role, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.modify_guild_role_positions/2`"

      @spec modify_guild_role_positions(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: [Crux.Structs.Role.position_resolvable()]
            ) ::
              {:ok, %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()}}
              | {:error, term()}

      def modify_guild_role_positions(guild, data) do
        Crux.Rest.Functions.modify_guild_role_positions(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.modify_guild_role_positions/2`, but raises an exception if it fails."

      @spec modify_guild_role_positions!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              data :: [Crux.Structs.Role.position_resolvable()]
            ) :: %{required(Crux.Structs.Snowflake.t()) => Crux.Structs.Role.t()} | no_return()

      def modify_guild_role_positions!(guild, data) do
        Crux.Rest.Functions.modify_guild_role_positions(guild, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.remove_guild_ban/3`"

      @spec remove_guild_ban(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def remove_guild_ban(guild, user, reason \\ nil) do
        Crux.Rest.Functions.remove_guild_ban(guild, user, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.remove_guild_ban/3`, but raises an exception if it fails."

      @spec remove_guild_ban!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              user :: Crux.Structs.User.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def remove_guild_ban!(guild, user, reason \\ nil) do
        Crux.Rest.Functions.remove_guild_ban(guild, user, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.remove_guild_member_role/4`"

      @spec remove_guild_member_role(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | {:error, term()}

      def remove_guild_member_role(guild, user, role, reason \\ nil) do
        Crux.Rest.Functions.remove_guild_member_role(guild, user, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.remove_guild_member_role/4`, but raises an exception if it fails."

      @spec remove_guild_member_role!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              member :: Crux.Structs.User.id_resolvable(),
              role :: Crux.Structs.Role.id_resolvable(),
              reason :: String.t() | nil
            ) :: :ok | no_return()

      def remove_guild_member_role!(guild, user, role, reason \\ nil) do
        Crux.Rest.Functions.remove_guild_member_role(guild, user, role, reason)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.sync_guild_integration/2`"

      @spec sync_guild_integration(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable()
            ) :: :ok | {:error, term()}

      def sync_guild_integration(guild, integration) do
        Crux.Rest.Functions.sync_guild_integration(guild, integration)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.sync_guild_integration/2`, but raises an exception if it fails."

      @spec sync_guild_integration!(
              guild :: Crux.Structs.Guild.id_resolvable(),
              integration_id :: Crux.Structs.Snowflake.resolvable()
            ) :: :ok | no_return()

      def sync_guild_integration!(guild, integration) do
        Crux.Rest.Functions.sync_guild_integration(guild, integration)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.trigger_typing/1`"

      @spec trigger_typing(channel :: Crux.Structs.Channel.id_resolvable()) ::
              :ok | {:error, term()}

      def trigger_typing(channel) do
        Crux.Rest.Functions.trigger_typing(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.trigger_typing/1`, but raises an exception if it fails."

      @spec trigger_typing!(channel :: Crux.Structs.Channel.id_resolvable()) :: :ok | no_return()

      def trigger_typing!(channel) do
        Crux.Rest.Functions.trigger_typing(channel)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end

      @doc "See `c:Crux.Rest.update_webhook/3`"

      @spec update_webhook(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t() | nil,
              data ::
                %{
                  optional(:name) => String.t(),
                  optional(:avatar) => Crux.Rest.Util.image(),
                  optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                }
                | [
                    {:name, String.t()}
                    | {:avatar, Crux.Rest.Util.image()}
                    | {:channel_id, Crux.Structs.Channel.id_resolvable()}
                  ]
            ) :: {:ok, Crux.Structs.Webhook.t()} | {:error, term()}

      def update_webhook(user, token \\ nil, data) do
        Crux.Rest.Functions.update_webhook(user, token, data)
        |> Crux.Rest.apply_options(@opts)
        |> request()
      end

      @doc "The same as `c:Crux.Rest.update_webhook/3`, but raises an exception if it fails."

      @spec update_webhook!(
              user :: Crux.Structs.User.id_resolvable(),
              token :: String.t() | nil,
              data ::
                %{
                  optional(:name) => String.t(),
                  optional(:avatar) => Crux.Rest.Util.image(),
                  optional(:channel_id) => Crux.Structs.Channel.id_resolvable()
                }
                | [
                    {:name, String.t()}
                    | {:avatar, Crux.Rest.Util.image()}
                    | {:channel_id, Crux.Structs.Channel.id_resolvable()}
                  ]
            ) :: Crux.Structs.Webhook.t() | no_return()

      def update_webhook!(user, token \\ nil, data) do
        Crux.Rest.Functions.update_webhook(user, token, data)
        |> Crux.Rest.apply_options(@opts)
        |> request!()
      end
    end
  end
end
