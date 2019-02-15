defmodule Crux.Rest.Gen.Bang do
  @moduledoc false
  # Generated 2019-02-15T18:30:23.947000Z

  alias Crux.Rest.Version
  require Version

  defmacro __using__(:callbacks) do
    quote location: :keep do
      @doc "The same as `c:create_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_message!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  args :: create_message_data()
                ) :: Message.t() | no_return()

      @doc "The same as `c:edit_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_message!(target :: Message.t(), args :: message_edit_data()) ::
                  Message.t() | no_return()

      @doc "The same as `c:edit_message/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_message!(
                  channel_id :: Crux.Rest.Util.channel_id_resolvable(),
                  message_id :: Crux.Rest.Util.message_id_resolvable(),
                  args :: message_edit_data()
                ) :: Message.t() | no_return()

      @doc "The same as `c:delete_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback delete_message!(message :: Message.t()) :: Message.t() | no_return()

      @doc "The same as `c:delete_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_message!(
                  channel_id :: Crux.Rest.Util.channel_id_resolvable(),
                  message_id :: Crux.Rest.Util.message_id_resolvable()
                ) :: Message | no_return()

      @doc "The same as `c:delete_messages/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_messages!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  messages :: [Crux.Rest.Util.message_id_resolvable()]
                ) :: :ok | no_return()

      @doc "The same as `c:get_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_message!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message_id :: Crux.Rest.Util.message_id_resolvable()
                ) :: Message | no_return()

      @doc "The same as `c:get_messages/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_messages!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  args :: get_messages_data()
                ) :: %{required(snowflake()) => Message.t()} | no_return()

      @doc "The same as `c:create_reaction/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_reaction!(
                  message :: Crux.Rest.Util.message_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:create_reaction/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_reaction!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:get_reactions/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_reactions!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable(),
                  args :: get_reactions_data()
                ) :: %{required(snowflake()) => User.t()} | no_return()

      @doc "The same as `c:get_reactions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_reactions!(
                  message :: Message.t(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable(),
                  args :: get_reactions_data()
                ) :: %{required(snowflake()) => User.t()} | no_return()

      @doc "The same as `c:delete_reaction/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_reaction!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_all_reactions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_all_reactions!(
                  message :: Message.t(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_all_reactions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_all_reactions!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:trigger_typing/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback trigger_typing!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
                  :ok | no_return()

      @doc "The same as `c:add_pinned_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback add_pinned_message!(message :: Message.t()) :: :ok | no_return()

      @doc "The same as `c:add_pinned_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_pinned_message!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:delete_pinned_message/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback delete_pinned_message!(message :: Message.t()) :: :ok | no_return()

      @doc "The same as `c:delete_pinned_message/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_pinned_message!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  message :: Crux.Rest.Util.message_id_resolvable()
                ) :: :ok | no_return()

      @doc "The same as `c:get_channel/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_channel!(channel :: Crux.Rest.Util.resolve_channel_id()) ::
                  Channel.t() | no_return()

      @doc "The same as `c:modify_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_channel!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  data :: modify_channel_data()
                ) :: Channel.t() | no_return()

      @doc "The same as `c:delete_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_channel!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  reason :: String.t()
                ) :: Channel.t() | no_return()

      @doc "The same as `c:edit_channel_permissions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback edit_channel_permissions!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  target :: Crux.Rest.Util.overwrite_target_resolvable(),
                  data :: edit_channel_permissions_data()
                ) :: :ok | no_return()

      @doc "The same as `c:get_channel_invites/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_channel_invites!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
                  %{required(String.t()) => Invite.t()} | no_return()

      @doc "The same as `c:create_channel_invite/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_channel_invite!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  args :: create_channel_invite_data()
                ) :: Invite.t() | no_return()

      @doc "The same as `c:delete_channel_permissions/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_channel_permissions!(
                  channel :: Crux.Rest.Util.channel_id_resolvable(),
                  target :: Crux.Rest.Util.overwrite_target_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:get_pinned_messages/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_pinned_messages!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
                  %{required(snowflake()) => Message.t()} | no_return()

      @doc "The same as `c:list_guild_emojis/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_emojis!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{required(snowflake()) => Emoji.t()} | no_return()

      @doc "The same as `c:get_guild_emoji/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_emoji!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_id_resolvable()
                ) :: Emoji | no_return()

      @doc "The same as `c:create_guild_emoji/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_emoji!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data :: create_guild_emoji_data()
                ) :: Emoji | no_return()

      @doc "The same as `c:modify_guild_emoji/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_emoji!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_id_resolvable(),
                  data :: modify_guild_emoji_data()
                ) :: Emoji | no_return()

      @doc "The same as `c:delete_guild_emoji/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_emoji!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  emoji :: Crux.Rest.Util.emoji_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:create_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback create_guild!(term()) :: Guild.t() | no_return()

      @doc "The same as `c:get_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  Guild.t() | no_return()

      @doc "The same as `c:modify_guild/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data :: modify_guild_data()
                ) :: Guild.t() | no_return()

      @doc "The same as `c:delete_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback delete_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) :: :ok | no_return()

      @doc "The same as `c:get_audit_logs/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_audit_logs!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  options :: audit_log_options() | nil
                ) :: AuditLog.t() | no_return()

      @doc "The same as `c:get_guild_channels/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_channels!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{required(snowflake()) => Channel.t()} | no_return()

      @doc "The same as `c:create_guild_channel/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_channel!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data :: create_guild_channel_data()
                ) :: Channel.t() | no_return()

      @doc "The same as `c:modify_guild_channel_positions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_channel_positions!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  channels :: [modify_guild_channel_positions_data_entry()]
                ) :: :ok | no_return()

      @doc "The same as `c:get_guild_member/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_member!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable()
                ) :: Member.t() | no_return()

      @doc "The same as `c:list_guild_members/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_members!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  options :: list_guild_members_options()
                ) :: %{required(snowflake()) => Member.t()} | no_return()

      @doc "The same as `c:add_guild_member/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_guild_member!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  data :: add_guild_member_data()
                ) :: Member.t() | no_return()

      @doc "The same as `c:modify_guild_member/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_member!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  member :: Crux.Rest.Util.user_id_resolvable(),
                  data :: modify_guild_member_data()
                ) :: :ok | no_return()

      @doc "The same as `c:modify_current_users_nick/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_current_users_nick!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  nick :: String.t(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:add_guild_member_role/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback add_guild_member_role!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  member :: Crux.Rest.Util.user_id_resolvable(),
                  role :: Crux.Rest.Util.role_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:remove_guild_member_role/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback remove_guild_member_role!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  member :: Crux.Rest.Util.user_id_resolvable(),
                  role :: Crux.Rest.Util.role_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:get_guild_bans/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_bans!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{
                    optional(snowflake()) => %{
                      required(:user) => User.t(),
                      required(:reason) => String.t() | nil
                    }
                  }
                  | no_return()

      @doc "The same as `c:get_guild_ban/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_ban!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable()
                ) ::
                  %{required(:user) => User.t(), required(:reason) => String.t() | nil}
                  | no_return()

      @doc "The same as `c:create_guild_ban/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_ban!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:remove_guild_ban/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback remove_guild_ban!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:get_guild_roles/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_roles!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{optional(snowflake()) => Role.t()} | no_return()

      @doc "The same as `c:create_guild_role/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_role!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data :: guild_role_data()
                ) :: Role.t() | no_return()

      @doc "The same as `c:modify_guild_role_positions/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_role_positions!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data :: Crux.Rest.Util.modify_guild_role_positions_data()
                ) :: %{optional(snowflake()) => Role.t()} | no_return()

      @doc "The same as `c:modify_guild_role/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_role!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  role :: Crux.Rest.Util.role_id_resolvable(),
                  data :: guild_role_data()
                ) :: Role.t() | no_return()

      @doc "The same as `c:delete_guild_role/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_role!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  role :: Crux.Rest.Util.role_id_resolvable(),
                  reason :: String.t()
                ) :: :ok | no_return()

      @doc "The same as `c:get_guild_prune_count/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_prune_count!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  days :: pos_integer()
                ) :: non_neg_integer() | no_return()

      @doc "The same as `c:begin_guild_prune/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback begin_guild_prune!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  opts :: begin_guild_prune_opts()
                ) :: non_neg_integer() | no_return()

      @doc "The same as `c:get_guild_voice_regions/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_voice_regions!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  term() | no_return()

      @doc "The same as `c:get_guild_invites/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_invites!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{optional(String.t()) => Invite.t()} | no_return()

      @doc "The same as `c:get_guild_integrations/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_integrations!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  list() | no_return()

      @doc "The same as `c:create_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_guild_integration!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data ::
                    %{required(:type) => String.t(), required(:id) => snowflake()}
                    | [{:type, String.t()} | {:id, snowflake()}]
                ) :: :ok | no_return()

      @doc "The same as `c:modify_guild_integration/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_integration!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
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
                ) :: :ok | no_return()

      @doc "The same as `c:delete_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_guild_integration!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  integration_id :: snowflake()
                ) :: :ok | no_return()

      @doc "The same as `c:sync_guild_integration/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback sync_guild_integration!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  integration_id :: snowflake()
                ) :: :ok | no_return()

      @doc "The same as `c:get_guild_embed/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_embed!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  term() | no_return()

      @doc "The same as `c:modify_guild_embed/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback modify_guild_embed!(
                  guild :: Crux.Rest.Util.guild_id_resolvable(),
                  data ::
                    %{optional(:enabled) => boolean(), optional(:channel_id) => snowflake()}
                    | [{:enabled, boolean()} | {:channel_id, snowflake()}]
                ) :: term() | no_return()

      @doc "The same as `c:get_guild_vanity_url/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_guild_vanity_url!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  String.t() | no_return()

      @doc "The same as `c:list_guild_webhooks/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_guild_webhooks!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
                  %{required(snowflake()) => Webhook.t()} | no_return()

      @doc "The same as `c:list_channel_webhooks/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback list_channel_webhooks!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
                  %{required(snowflake()) => Webhook.t()} | no_return()

      @doc "The same as `c:get_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t() | nil
                ) :: Webhook.t() | no_return()

      @doc "The same as `c:update_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback update_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t() | nil,
                  data ::
                    %{
                      optional(:name) => String.t(),
                      optional(:avatar) => Crux.Rest.Util.image(),
                      optional(:channel_id) => snowflake()
                    }
                    | [
                        {:name, String.t()}
                        | {:avatar, Crux.Rest.Util.image()}
                        | {:channel_id, snowflake()}
                      ]
                ) :: Webhook.t() | no_return()

      @doc "The same as `c:delete_webhook/2`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t() | nil
                ) :: :ok | no_return()

      @doc "The same as `c:execute_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_webhook!(
                  webhook :: Webhook.t(),
                  wait :: boolean() | nil,
                  data :: execute_webhook_options()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t(),
                  wait :: boolean() | nil,
                  data :: execute_webhook_options()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_slack_webhook/3`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_slack_webhook!(
                  webhook :: Webhook.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_slack_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_slack_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_github_webhook/4`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_github_webhook!(
                  webhook :: Webhook.t(),
                  event :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:execute_github_webhook/5`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback execute_github_webhook!(
                  user :: Crux.Rest.Util.user_id_resolvable(),
                  token :: String.t(),
                  event :: String.t(),
                  wait :: boolean() | nil,
                  data :: term()
                ) :: :ok | no_return()

      @doc "The same as `c:get_invite/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback get_invite!(code :: String.t()) :: Invite.t() | no_return()

      @doc "The same as `c:delete_invite/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback delete_invite!(invite_or_code :: String.t() | Invite.t()) ::
                  Invite.t() | no_return()

      @doc "The same as `c:get_user/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_user!(user :: Crux.Rest.Util.user_id_resolvable() | String.t()) ::
                  User.t() | no_return()

      @doc "The same as `c:modify_current_user/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback modify_current_user!(data :: modify_current_user_data()) :: User.t() | no_return()

      @doc "The same as `c:get_current_user_guilds/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback get_current_user_guilds!(data :: get_current_user_guild_data()) ::
                  %{required(snowflake()) => Guild.t()} | no_return()

      @doc "The same as `c:leave_guild/1`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback leave_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) :: :ok | no_return()

      @doc "The same as `c:get_user_dms/0`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback get_user_dms!() :: %{required(snowflake()) => Channel.t()} | no_return()

      @doc "The same as `c:create_dm/1`, but raises an exception if it fails."
      Version.since("0.2.0")

      @callback create_dm!(user :: Crux.Rest.Util.user_id_resolvable()) ::
                  Channel.t() | no_return()

      @doc "The same as `c:gateway/0`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback gateway!() :: term() | no_return()

      @doc "The same as `c:gateway_bot/0`, but raises an exception if it fails."
      Version.since("0.2.0")
      @callback gateway_bot!() :: term() | no_return()

      # Required for `Crux.Rest.Functions`
      @optional_callbacks create_message!: 2,
                          edit_message!: 2,
                          edit_message!: 3,
                          delete_message!: 1,
                          delete_message!: 2,
                          delete_messages!: 2,
                          get_message!: 2,
                          get_messages!: 2,
                          create_reaction!: 2,
                          create_reaction!: 3,
                          get_reactions!: 4,
                          get_reactions!: 3,
                          delete_reaction!: 4,
                          delete_all_reactions!: 2,
                          delete_all_reactions!: 3,
                          trigger_typing!: 1,
                          add_pinned_message!: 1,
                          add_pinned_message!: 2,
                          delete_pinned_message!: 1,
                          delete_pinned_message!: 2,
                          get_channel!: 1,
                          modify_channel!: 2,
                          delete_channel!: 2,
                          edit_channel_permissions!: 3,
                          get_channel_invites!: 1,
                          create_channel_invite!: 2,
                          delete_channel_permissions!: 3,
                          get_pinned_messages!: 1,
                          list_guild_emojis!: 1,
                          get_guild_emoji!: 2,
                          create_guild_emoji!: 2,
                          modify_guild_emoji!: 3,
                          delete_guild_emoji!: 3,
                          create_guild!: 1,
                          get_guild!: 1,
                          modify_guild!: 2,
                          delete_guild!: 1,
                          get_audit_logs!: 2,
                          get_guild_channels!: 1,
                          create_guild_channel!: 2,
                          modify_guild_channel_positions!: 2,
                          get_guild_member!: 2,
                          list_guild_members!: 2,
                          add_guild_member!: 3,
                          modify_guild_member!: 3,
                          modify_current_users_nick!: 3,
                          add_guild_member_role!: 4,
                          remove_guild_member_role!: 4,
                          get_guild_bans!: 1,
                          get_guild_ban!: 2,
                          create_guild_ban!: 3,
                          remove_guild_ban!: 3,
                          get_guild_roles!: 1,
                          create_guild_role!: 2,
                          modify_guild_role_positions!: 2,
                          modify_guild_role!: 3,
                          delete_guild_role!: 3,
                          get_guild_prune_count!: 2,
                          begin_guild_prune!: 2,
                          get_guild_voice_regions!: 1,
                          get_guild_invites!: 1,
                          get_guild_integrations!: 1,
                          create_guild_integration!: 2,
                          modify_guild_integration!: 3,
                          delete_guild_integration!: 2,
                          sync_guild_integration!: 2,
                          get_guild_embed!: 1,
                          modify_guild_embed!: 2,
                          get_guild_vanity_url!: 1,
                          list_guild_webhooks!: 1,
                          list_channel_webhooks!: 1,
                          get_webhook!: 2,
                          update_webhook!: 3,
                          delete_webhook!: 2,
                          execute_webhook!: 3,
                          execute_webhook!: 4,
                          execute_slack_webhook!: 3,
                          execute_slack_webhook!: 4,
                          execute_github_webhook!: 4,
                          execute_github_webhook!: 5,
                          get_invite!: 1,
                          delete_invite!: 1,
                          get_user!: 1,
                          modify_current_user!: 1,
                          get_current_user_guilds!: 1,
                          leave_guild!: 1,
                          get_user_dms!: 0,
                          create_dm!: 1,
                          gateway!: 0,
                          gateway_bot!: 0
    end
  end

  defmacro __using__(:functions) do
    quote location: :keep do
      def add_guild_member(guild, user, data) do
        request = Crux.Rest.Functions.add_guild_member(guild, user, data)
        Crux.Rest.request(@name, request)
      end

      def add_guild_member!(guild, user, data) do
        request = Crux.Rest.Functions.add_guild_member(guild, user, data)
        Crux.Rest.request!(@name, request)
      end

      def add_guild_member_role(guild, member, role, reason) do
        request = Crux.Rest.Functions.add_guild_member_role(guild, member, role, reason)
        Crux.Rest.request(@name, request)
      end

      def add_guild_member_role!(guild, member, role, reason) do
        request = Crux.Rest.Functions.add_guild_member_role(guild, member, role, reason)
        Crux.Rest.request!(@name, request)
      end

      def add_pinned_message(map) do
        request = Crux.Rest.Functions.add_pinned_message(map)
        Crux.Rest.request(@name, request)
      end

      def add_pinned_message!(map) do
        request = Crux.Rest.Functions.add_pinned_message(map)
        Crux.Rest.request!(@name, request)
      end

      def add_pinned_message(channel, message) do
        request = Crux.Rest.Functions.add_pinned_message(channel, message)
        Crux.Rest.request(@name, request)
      end

      def add_pinned_message!(channel, message) do
        request = Crux.Rest.Functions.add_pinned_message(channel, message)
        Crux.Rest.request!(@name, request)
      end

      def begin_guild_prune(guild, data) do
        request = Crux.Rest.Functions.begin_guild_prune(guild, data)
        Crux.Rest.request(@name, request)
      end

      def begin_guild_prune!(guild, data) do
        request = Crux.Rest.Functions.begin_guild_prune(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def create_channel_invite(channel, data) do
        request = Crux.Rest.Functions.create_channel_invite(channel, data)
        Crux.Rest.request(@name, request)
      end

      def create_channel_invite!(channel, data) do
        request = Crux.Rest.Functions.create_channel_invite(channel, data)
        Crux.Rest.request!(@name, request)
      end

      def create_dm(user) do
        request = Crux.Rest.Functions.create_dm(user)
        Crux.Rest.request(@name, request)
      end

      def create_dm!(user) do
        request = Crux.Rest.Functions.create_dm(user)
        Crux.Rest.request!(@name, request)
      end

      def create_guild(data) do
        request = Crux.Rest.Functions.create_guild(data)
        Crux.Rest.request(@name, request)
      end

      def create_guild!(data) do
        request = Crux.Rest.Functions.create_guild(data)
        Crux.Rest.request!(@name, request)
      end

      def create_guild_ban(guild, user, reason \\ nil) do
        request = Crux.Rest.Functions.create_guild_ban(guild, user, reason)
        Crux.Rest.request(@name, request)
      end

      def create_guild_ban!(guild, user, reason \\ nil) do
        request = Crux.Rest.Functions.create_guild_ban(guild, user, reason)
        Crux.Rest.request!(@name, request)
      end

      def create_guild_channel(guild, data) do
        request = Crux.Rest.Functions.create_guild_channel(guild, data)
        Crux.Rest.request(@name, request)
      end

      def create_guild_channel!(guild, data) do
        request = Crux.Rest.Functions.create_guild_channel(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def create_guild_emoji(guild, data) do
        request = Crux.Rest.Functions.create_guild_emoji(guild, data)
        Crux.Rest.request(@name, request)
      end

      def create_guild_emoji!(guild, data) do
        request = Crux.Rest.Functions.create_guild_emoji(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def create_guild_integration(guild, data) do
        request = Crux.Rest.Functions.create_guild_integration(guild, data)
        Crux.Rest.request(@name, request)
      end

      def create_guild_integration!(guild, data) do
        request = Crux.Rest.Functions.create_guild_integration(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def create_guild_role(guild, data) do
        request = Crux.Rest.Functions.create_guild_role(guild, data)
        Crux.Rest.request(@name, request)
      end

      def create_guild_role!(guild, data) do
        request = Crux.Rest.Functions.create_guild_role(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def create_message(channel_or_message, data) do
        request = Crux.Rest.Functions.create_message(channel_or_message, data)
        Crux.Rest.request(@name, request)
      end

      def create_message!(channel_or_message, data) do
        request = Crux.Rest.Functions.create_message(channel_or_message, data)
        Crux.Rest.request!(@name, request)
      end

      def create_reaction(map, emoji) do
        request = Crux.Rest.Functions.create_reaction(map, emoji)
        Crux.Rest.request(@name, request)
      end

      def create_reaction!(map, emoji) do
        request = Crux.Rest.Functions.create_reaction(map, emoji)
        Crux.Rest.request!(@name, request)
      end

      def create_reaction(channel, message, emoji) do
        request = Crux.Rest.Functions.create_reaction(channel, message, emoji)
        Crux.Rest.request(@name, request)
      end

      def create_reaction!(channel, message, emoji) do
        request = Crux.Rest.Functions.create_reaction(channel, message, emoji)
        Crux.Rest.request!(@name, request)
      end

      def delete_all_reactions(map, emoji) do
        request = Crux.Rest.Functions.delete_all_reactions(map, emoji)
        Crux.Rest.request(@name, request)
      end

      def delete_all_reactions!(map, emoji) do
        request = Crux.Rest.Functions.delete_all_reactions(map, emoji)
        Crux.Rest.request!(@name, request)
      end

      def delete_all_reactions(channel, message, emoji) do
        request = Crux.Rest.Functions.delete_all_reactions(channel, message, emoji)
        Crux.Rest.request(@name, request)
      end

      def delete_all_reactions!(channel, message, emoji) do
        request = Crux.Rest.Functions.delete_all_reactions(channel, message, emoji)
        Crux.Rest.request!(@name, request)
      end

      def delete_channel(channel, reason \\ nil) do
        request = Crux.Rest.Functions.delete_channel(channel, reason)
        Crux.Rest.request(@name, request)
      end

      def delete_channel!(channel, reason \\ nil) do
        request = Crux.Rest.Functions.delete_channel(channel, reason)
        Crux.Rest.request!(@name, request)
      end

      def delete_channel_permissions(channel, target, reason \\ nil) do
        request = Crux.Rest.Functions.delete_channel_permissions(channel, target, reason)
        Crux.Rest.request(@name, request)
      end

      def delete_channel_permissions!(channel, target, reason \\ nil) do
        request = Crux.Rest.Functions.delete_channel_permissions(channel, target, reason)
        Crux.Rest.request!(@name, request)
      end

      def delete_guild(guild) do
        request = Crux.Rest.Functions.delete_guild(guild)
        Crux.Rest.request(@name, request)
      end

      def delete_guild!(guild) do
        request = Crux.Rest.Functions.delete_guild(guild)
        Crux.Rest.request!(@name, request)
      end

      def delete_guild_emoji(guild, emoji, reason \\ nil) do
        request = Crux.Rest.Functions.delete_guild_emoji(guild, emoji, reason)
        Crux.Rest.request(@name, request)
      end

      def delete_guild_emoji!(guild, emoji, reason \\ nil) do
        request = Crux.Rest.Functions.delete_guild_emoji(guild, emoji, reason)
        Crux.Rest.request!(@name, request)
      end

      def delete_guild_integration(guild, integration) do
        request = Crux.Rest.Functions.delete_guild_integration(guild, integration)
        Crux.Rest.request(@name, request)
      end

      def delete_guild_integration!(guild, integration) do
        request = Crux.Rest.Functions.delete_guild_integration(guild, integration)
        Crux.Rest.request!(@name, request)
      end

      def delete_guild_role(guild, role, reason \\ nil) do
        request = Crux.Rest.Functions.delete_guild_role(guild, role, reason)
        Crux.Rest.request(@name, request)
      end

      def delete_guild_role!(guild, role, reason \\ nil) do
        request = Crux.Rest.Functions.delete_guild_role(guild, role, reason)
        Crux.Rest.request!(@name, request)
      end

      def delete_invite(code) do
        request = Crux.Rest.Functions.delete_invite(code)
        Crux.Rest.request(@name, request)
      end

      def delete_invite!(code) do
        request = Crux.Rest.Functions.delete_invite(code)
        Crux.Rest.request!(@name, request)
      end

      def delete_message(map) do
        request = Crux.Rest.Functions.delete_message(map)
        Crux.Rest.request(@name, request)
      end

      def delete_message!(map) do
        request = Crux.Rest.Functions.delete_message(map)
        Crux.Rest.request!(@name, request)
      end

      def delete_message(channel, message) do
        request = Crux.Rest.Functions.delete_message(channel, message)
        Crux.Rest.request(@name, request)
      end

      def delete_message!(channel, message) do
        request = Crux.Rest.Functions.delete_message(channel, message)
        Crux.Rest.request!(@name, request)
      end

      def delete_messages(channel, messages) do
        request = Crux.Rest.Functions.delete_messages(channel, messages)
        Crux.Rest.request(@name, request)
      end

      def delete_messages!(channel, messages) do
        request = Crux.Rest.Functions.delete_messages(channel, messages)
        Crux.Rest.request!(@name, request)
      end

      def delete_pinned_message(map) do
        request = Crux.Rest.Functions.delete_pinned_message(map)
        Crux.Rest.request(@name, request)
      end

      def delete_pinned_message!(map) do
        request = Crux.Rest.Functions.delete_pinned_message(map)
        Crux.Rest.request!(@name, request)
      end

      def delete_pinned_message(channel, message) do
        request = Crux.Rest.Functions.delete_pinned_message(channel, message)
        Crux.Rest.request(@name, request)
      end

      def delete_pinned_message!(channel, message) do
        request = Crux.Rest.Functions.delete_pinned_message(channel, message)
        Crux.Rest.request!(@name, request)
      end

      def delete_reaction(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user \\ "@me",
            mayber_user \\ "@me"
          ) do
        request =
          Crux.Rest.Functions.delete_reaction(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user,
            mayber_user
          )

        Crux.Rest.request(@name, request)
      end

      def delete_reaction!(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user \\ "@me",
            mayber_user \\ "@me"
          ) do
        request =
          Crux.Rest.Functions.delete_reaction(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user,
            mayber_user
          )

        Crux.Rest.request!(@name, request)
      end

      def delete_webhook(user, token \\ nil) do
        request = Crux.Rest.Functions.delete_webhook(user, token)
        Crux.Rest.request(@name, request)
      end

      def delete_webhook!(user, token \\ nil) do
        request = Crux.Rest.Functions.delete_webhook(user, token)
        Crux.Rest.request!(@name, request)
      end

      def edit_channel_permissions(channel, target, data) do
        request = Crux.Rest.Functions.edit_channel_permissions(channel, target, data)
        Crux.Rest.request(@name, request)
      end

      def edit_channel_permissions!(channel, target, data) do
        request = Crux.Rest.Functions.edit_channel_permissions(channel, target, data)
        Crux.Rest.request!(@name, request)
      end

      def edit_message(map, data) do
        request = Crux.Rest.Functions.edit_message(map, data)
        Crux.Rest.request(@name, request)
      end

      def edit_message!(map, data) do
        request = Crux.Rest.Functions.edit_message(map, data)
        Crux.Rest.request!(@name, request)
      end

      def edit_message(channel, message, data) do
        request = Crux.Rest.Functions.edit_message(channel, message, data)
        Crux.Rest.request(@name, request)
      end

      def edit_message!(channel, message, data) do
        request = Crux.Rest.Functions.edit_message(channel, message, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_github_webhook(map, event, data) do
        request = Crux.Rest.Functions.execute_github_webhook(map, event, data)
        Crux.Rest.request(@name, request)
      end

      def execute_github_webhook!(map, event, data) do
        request = Crux.Rest.Functions.execute_github_webhook(map, event, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_github_webhook(user, token, event, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_github_webhook(user, token, event, wait, data)
        Crux.Rest.request(@name, request)
      end

      def execute_github_webhook!(user, token, event, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_github_webhook(user, token, event, wait, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_slack_webhook(map, data) do
        request = Crux.Rest.Functions.execute_slack_webhook(map, data)
        Crux.Rest.request(@name, request)
      end

      def execute_slack_webhook!(map, data) do
        request = Crux.Rest.Functions.execute_slack_webhook(map, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_slack_webhook(user, token, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_slack_webhook(user, token, wait, data)
        Crux.Rest.request(@name, request)
      end

      def execute_slack_webhook!(user, token, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_slack_webhook(user, token, wait, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_webhook(map, data) do
        request = Crux.Rest.Functions.execute_webhook(map, data)
        Crux.Rest.request(@name, request)
      end

      def execute_webhook!(map, data) do
        request = Crux.Rest.Functions.execute_webhook(map, data)
        Crux.Rest.request!(@name, request)
      end

      def execute_webhook(user, token, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_webhook(user, token, wait, data)
        Crux.Rest.request(@name, request)
      end

      def execute_webhook!(user, token, wait \\ false, data) do
        request = Crux.Rest.Functions.execute_webhook(user, token, wait, data)
        Crux.Rest.request!(@name, request)
      end

      def gateway() do
        request = Crux.Rest.Functions.gateway()
        Crux.Rest.request(@name, request)
      end

      def gateway!() do
        request = Crux.Rest.Functions.gateway()
        Crux.Rest.request!(@name, request)
      end

      def gateway_bot() do
        request = Crux.Rest.Functions.gateway_bot()
        Crux.Rest.request(@name, request)
      end

      def gateway_bot!() do
        request = Crux.Rest.Functions.gateway_bot()
        Crux.Rest.request!(@name, request)
      end

      def get_audit_logs(guild, data \\ []) do
        request = Crux.Rest.Functions.get_audit_logs(guild, data)
        Crux.Rest.request(@name, request)
      end

      def get_audit_logs!(guild, data \\ []) do
        request = Crux.Rest.Functions.get_audit_logs(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def get_channel(channel) do
        request = Crux.Rest.Functions.get_channel(channel)
        Crux.Rest.request(@name, request)
      end

      def get_channel!(channel) do
        request = Crux.Rest.Functions.get_channel(channel)
        Crux.Rest.request!(@name, request)
      end

      def get_channel_invites(channel) do
        request = Crux.Rest.Functions.get_channel_invites(channel)
        Crux.Rest.request(@name, request)
      end

      def get_channel_invites!(channel) do
        request = Crux.Rest.Functions.get_channel_invites(channel)
        Crux.Rest.request!(@name, request)
      end

      def get_current_user_guilds(data) do
        request = Crux.Rest.Functions.get_current_user_guilds(data)
        Crux.Rest.request(@name, request)
      end

      def get_current_user_guilds!(data) do
        request = Crux.Rest.Functions.get_current_user_guilds(data)
        Crux.Rest.request!(@name, request)
      end

      def get_guild(guild) do
        request = Crux.Rest.Functions.get_guild(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild!(guild) do
        request = Crux.Rest.Functions.get_guild(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_ban(guild, user) do
        request = Crux.Rest.Functions.get_guild_ban(guild, user)
        Crux.Rest.request(@name, request)
      end

      def get_guild_ban!(guild, user) do
        request = Crux.Rest.Functions.get_guild_ban(guild, user)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_bans(guild) do
        request = Crux.Rest.Functions.get_guild_bans(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_bans!(guild) do
        request = Crux.Rest.Functions.get_guild_bans(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_channels(guild) do
        request = Crux.Rest.Functions.get_guild_channels(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_channels!(guild) do
        request = Crux.Rest.Functions.get_guild_channels(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_embed(guild) do
        request = Crux.Rest.Functions.get_guild_embed(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_embed!(guild) do
        request = Crux.Rest.Functions.get_guild_embed(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_emoji(guild, emoji) do
        request = Crux.Rest.Functions.get_guild_emoji(guild, emoji)
        Crux.Rest.request(@name, request)
      end

      def get_guild_emoji!(guild, emoji) do
        request = Crux.Rest.Functions.get_guild_emoji(guild, emoji)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_integrations(guild) do
        request = Crux.Rest.Functions.get_guild_integrations(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_integrations!(guild) do
        request = Crux.Rest.Functions.get_guild_integrations(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_invites(guild) do
        request = Crux.Rest.Functions.get_guild_invites(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_invites!(guild) do
        request = Crux.Rest.Functions.get_guild_invites(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_member(guild, user) do
        request = Crux.Rest.Functions.get_guild_member(guild, user)
        Crux.Rest.request(@name, request)
      end

      def get_guild_member!(guild, user) do
        request = Crux.Rest.Functions.get_guild_member(guild, user)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_prune_count(guild, days) do
        request = Crux.Rest.Functions.get_guild_prune_count(guild, days)
        Crux.Rest.request(@name, request)
      end

      def get_guild_prune_count!(guild, days) do
        request = Crux.Rest.Functions.get_guild_prune_count(guild, days)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_roles(guild) do
        request = Crux.Rest.Functions.get_guild_roles(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_roles!(guild) do
        request = Crux.Rest.Functions.get_guild_roles(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_vanity_url(guild) do
        request = Crux.Rest.Functions.get_guild_vanity_url(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_vanity_url!(guild) do
        request = Crux.Rest.Functions.get_guild_vanity_url(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_guild_voice_regions(guild) do
        request = Crux.Rest.Functions.get_guild_voice_regions(guild)
        Crux.Rest.request(@name, request)
      end

      def get_guild_voice_regions!(guild) do
        request = Crux.Rest.Functions.get_guild_voice_regions(guild)
        Crux.Rest.request!(@name, request)
      end

      def get_invite(code) do
        request = Crux.Rest.Functions.get_invite(code)
        Crux.Rest.request(@name, request)
      end

      def get_invite!(code) do
        request = Crux.Rest.Functions.get_invite(code)
        Crux.Rest.request!(@name, request)
      end

      def get_message(message_or_channel, data_or_channel \\ [], data \\ []) do
        request = Crux.Rest.Functions.get_message(message_or_channel, data_or_channel, data)
        Crux.Rest.request(@name, request)
      end

      def get_message!(message_or_channel, data_or_channel \\ [], data \\ []) do
        request = Crux.Rest.Functions.get_message(message_or_channel, data_or_channel, data)
        Crux.Rest.request!(@name, request)
      end

      def get_messages(channel, data) do
        request = Crux.Rest.Functions.get_messages(channel, data)
        Crux.Rest.request(@name, request)
      end

      def get_messages!(channel, data) do
        request = Crux.Rest.Functions.get_messages(channel, data)
        Crux.Rest.request!(@name, request)
      end

      def get_pinned_messages(channel) do
        request = Crux.Rest.Functions.get_pinned_messages(channel)
        Crux.Rest.request(@name, request)
      end

      def get_pinned_messages!(channel) do
        request = Crux.Rest.Functions.get_pinned_messages(channel)
        Crux.Rest.request!(@name, request)
      end

      def get_reactions(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data \\ [],
            maybe_data \\ []
          ) do
        request =
          Crux.Rest.Functions.get_reactions(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data,
            maybe_data
          )

        Crux.Rest.request(@name, request)
      end

      def get_reactions!(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data \\ [],
            maybe_data \\ []
          ) do
        request =
          Crux.Rest.Functions.get_reactions(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data,
            maybe_data
          )

        Crux.Rest.request!(@name, request)
      end

      def get_user(user) do
        request = Crux.Rest.Functions.get_user(user)
        Crux.Rest.request(@name, request)
      end

      def get_user!(user) do
        request = Crux.Rest.Functions.get_user(user)
        Crux.Rest.request!(@name, request)
      end

      def get_user_dms() do
        request = Crux.Rest.Functions.get_user_dms()
        Crux.Rest.request(@name, request)
      end

      def get_user_dms!() do
        request = Crux.Rest.Functions.get_user_dms()
        Crux.Rest.request!(@name, request)
      end

      def get_webhook(user, token \\ nil) do
        request = Crux.Rest.Functions.get_webhook(user, token)
        Crux.Rest.request(@name, request)
      end

      def get_webhook!(user, token \\ nil) do
        request = Crux.Rest.Functions.get_webhook(user, token)
        Crux.Rest.request!(@name, request)
      end

      def leave_guild(guild) do
        request = Crux.Rest.Functions.leave_guild(guild)
        Crux.Rest.request(@name, request)
      end

      def leave_guild!(guild) do
        request = Crux.Rest.Functions.leave_guild(guild)
        Crux.Rest.request!(@name, request)
      end

      def list_channel_webhooks(channel) do
        request = Crux.Rest.Functions.list_channel_webhooks(channel)
        Crux.Rest.request(@name, request)
      end

      def list_channel_webhooks!(channel) do
        request = Crux.Rest.Functions.list_channel_webhooks(channel)
        Crux.Rest.request!(@name, request)
      end

      def list_guild_emojis(guild) do
        request = Crux.Rest.Functions.list_guild_emojis(guild)
        Crux.Rest.request(@name, request)
      end

      def list_guild_emojis!(guild) do
        request = Crux.Rest.Functions.list_guild_emojis(guild)
        Crux.Rest.request!(@name, request)
      end

      def list_guild_members(guild, options) do
        request = Crux.Rest.Functions.list_guild_members(guild, options)
        Crux.Rest.request(@name, request)
      end

      def list_guild_members!(guild, options) do
        request = Crux.Rest.Functions.list_guild_members(guild, options)
        Crux.Rest.request!(@name, request)
      end

      def list_guild_webhooks(guild) do
        request = Crux.Rest.Functions.list_guild_webhooks(guild)
        Crux.Rest.request(@name, request)
      end

      def list_guild_webhooks!(guild) do
        request = Crux.Rest.Functions.list_guild_webhooks(guild)
        Crux.Rest.request!(@name, request)
      end

      def modify_channel(channel, data) do
        request = Crux.Rest.Functions.modify_channel(channel, data)
        Crux.Rest.request(@name, request)
      end

      def modify_channel!(channel, data) do
        request = Crux.Rest.Functions.modify_channel(channel, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_current_user(data) do
        request = Crux.Rest.Functions.modify_current_user(data)
        Crux.Rest.request(@name, request)
      end

      def modify_current_user!(data) do
        request = Crux.Rest.Functions.modify_current_user(data)
        Crux.Rest.request!(@name, request)
      end

      def modify_current_users_nick(guild, nick, reason) do
        request = Crux.Rest.Functions.modify_current_users_nick(guild, nick, reason)
        Crux.Rest.request(@name, request)
      end

      def modify_current_users_nick!(guild, nick, reason) do
        request = Crux.Rest.Functions.modify_current_users_nick(guild, nick, reason)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild(guild, data) do
        request = Crux.Rest.Functions.modify_guild(guild, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild!(guild, data) do
        request = Crux.Rest.Functions.modify_guild(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_channel_positions(guild, channels) do
        request = Crux.Rest.Functions.modify_guild_channel_positions(guild, channels)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_channel_positions!(guild, channels) do
        request = Crux.Rest.Functions.modify_guild_channel_positions(guild, channels)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_embed(guild, data) do
        request = Crux.Rest.Functions.modify_guild_embed(guild, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_embed!(guild, data) do
        request = Crux.Rest.Functions.modify_guild_embed(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_emoji(guild, emoji, data) do
        request = Crux.Rest.Functions.modify_guild_emoji(guild, emoji, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_emoji!(guild, emoji, data) do
        request = Crux.Rest.Functions.modify_guild_emoji(guild, emoji, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_integration(guild, integration, data) do
        request = Crux.Rest.Functions.modify_guild_integration(guild, integration, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_integration!(guild, integration, data) do
        request = Crux.Rest.Functions.modify_guild_integration(guild, integration, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_member(guild, member, data) do
        request = Crux.Rest.Functions.modify_guild_member(guild, member, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_member!(guild, member, data) do
        request = Crux.Rest.Functions.modify_guild_member(guild, member, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_role(guild, role, data) do
        request = Crux.Rest.Functions.modify_guild_role(guild, role, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_role!(guild, role, data) do
        request = Crux.Rest.Functions.modify_guild_role(guild, role, data)
        Crux.Rest.request!(@name, request)
      end

      def modify_guild_role_positions(guild, data) do
        request = Crux.Rest.Functions.modify_guild_role_positions(guild, data)
        Crux.Rest.request(@name, request)
      end

      def modify_guild_role_positions!(guild, data) do
        request = Crux.Rest.Functions.modify_guild_role_positions(guild, data)
        Crux.Rest.request!(@name, request)
      end

      def remove_guild_ban(guild, user, reason \\ nil) do
        request = Crux.Rest.Functions.remove_guild_ban(guild, user, reason)
        Crux.Rest.request(@name, request)
      end

      def remove_guild_ban!(guild, user, reason \\ nil) do
        request = Crux.Rest.Functions.remove_guild_ban(guild, user, reason)
        Crux.Rest.request!(@name, request)
      end

      def remove_guild_member_role(guild, member, role, reason \\ nil) do
        request = Crux.Rest.Functions.remove_guild_member_role(guild, member, role, reason)
        Crux.Rest.request(@name, request)
      end

      def remove_guild_member_role!(guild, member, role, reason \\ nil) do
        request = Crux.Rest.Functions.remove_guild_member_role(guild, member, role, reason)
        Crux.Rest.request!(@name, request)
      end

      def sync_guild_integration(guild, integration) do
        request = Crux.Rest.Functions.sync_guild_integration(guild, integration)
        Crux.Rest.request(@name, request)
      end

      def sync_guild_integration!(guild, integration) do
        request = Crux.Rest.Functions.sync_guild_integration(guild, integration)
        Crux.Rest.request!(@name, request)
      end

      def trigger_typing(channel) do
        request = Crux.Rest.Functions.trigger_typing(channel)
        Crux.Rest.request(@name, request)
      end

      def trigger_typing!(channel) do
        request = Crux.Rest.Functions.trigger_typing(channel)
        Crux.Rest.request!(@name, request)
      end

      def update_webhook(user, token \\ nil, data) do
        request = Crux.Rest.Functions.update_webhook(user, token, data)
        Crux.Rest.request(@name, request)
      end

      def update_webhook!(user, token \\ nil, data) do
        request = Crux.Rest.Functions.update_webhook(user, token, data)
        Crux.Rest.request!(@name, request)
      end
    end
  end
end
