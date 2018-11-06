defmodule Crux.Rest.Bang do
  @moduledoc false
  # Generated 2018-11-06T18:47:33.831000Z

  alias Crux.Rest.Version
  require Version

  defmacro __using__(_) do
    quote location: :keep do
      @doc "The same as `add_guild_member/3`, but raises an exception if it fails."
      @spec add_guild_member!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable(),
              data :: add_guild_member_data()
            ) :: Crux.Structs.Member.t() | no_return()
      Version.since("0.1.0")

      def add_guild_member!(guild, user, data) do
        case Crux.Rest.add_guild_member(guild, user, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `add_guild_member_role/4`, but raises an exception if it fails."
      @spec add_guild_member_role!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              member :: Crux.Rest.Util.user_id_resolvable(),
              role :: Crux.Rest.Util.role_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.1")

      def add_guild_member_role!(guild, member, role, reason \\ nil) do
        case Crux.Rest.add_guild_member_role(guild, member, role, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `add_pinned_message/1`, but raises an exception if it fails."
      @spec add_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()
      Version.since("0.1.0")

      def add_pinned_message!(message) do
        case Crux.Rest.add_pinned_message(message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `add_pinned_message/2`, but raises an exception if it fails."
      @spec add_pinned_message!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def add_pinned_message!(channel, message) do
        case Crux.Rest.add_pinned_message(channel, message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `begin_guild_prune/2`, but raises an exception if it fails."
      @spec begin_guild_prune!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              days :: pos_integer()
            ) :: non_neg_integer() | no_return()
      Version.since("0.1.2")

      def begin_guild_prune!(guild, days) do
        case Crux.Rest.begin_guild_prune(guild, days) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_channel_invite/2`, but raises an exception if it fails."
      @spec create_channel_invite!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              args :: create_channel_invite_data()
            ) :: Crux.Structs.Invite.t() | no_return()
      Version.since("0.1.0")

      def create_channel_invite!(channel, args) do
        case Crux.Rest.create_channel_invite(channel, args) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_dm/1`, but raises an exception if it fails."
      @spec create_dm!(user :: Crux.Rest.Util.user_id_resolvable()) ::
              Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.4")

      def create_dm!(user) do
        case Crux.Rest.create_dm(user) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_group_dm/1`, but raises an exception if it fails."
      @spec create_group_dm!(data :: create_group_dm_data()) ::
              Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.4")

      def create_group_dm!(data) do
        case Crux.Rest.create_group_dm(data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_guild/1`, but raises an exception if it fails."

      Version.since("0.1.0")

      def create_guild!(data) do
        case Crux.Rest.create_guild(data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_guild_ban/3`, but raises an exception if it fails."
      @spec create_guild_ban!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def create_guild_ban!(guild, user, reason \\ nil) do
        case Crux.Rest.create_guild_ban(guild, user, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_guild_channel/2`, but raises an exception if it fails."
      @spec create_guild_channel!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data :: create_guild_channel_data()
            ) :: Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.0")

      def create_guild_channel!(guild, data) do
        case Crux.Rest.create_guild_channel(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_guild_emoji/2`, but raises an exception if it fails."
      @spec create_guild_emoji!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data :: create_guild_emoji_data()
            ) :: Crux.Structs.Emoji | no_return()
      Version.since("0.1.0")

      def create_guild_emoji!(guild, data) do
        case Crux.Rest.create_guild_emoji(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_guild_integration/2`, but raises an exception if it fails."
      @spec create_guild_integration!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data ::
                %{required(:type) => String.t(), required(:id) => snowflake()}
                | [{:type, String.t()} | {:id, snowflake()}]
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def create_guild_integration!(guild, data) do
        case Crux.Rest.create_guild_integration(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_message/2`, but raises an exception if it fails."
      @spec create_message!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              args :: create_message_data()
            ) :: Crux.Structs.Message.t() | no_return()
      Version.since("0.1.0")

      def create_message!(channel_or_message, args) do
        case Crux.Rest.create_message(channel_or_message, args) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_reaction/2`, but raises an exception if it fails."
      @spec create_reaction!(
              message :: Crux.Rest.Util.message_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def create_reaction!(message, emoji) do
        case Crux.Rest.create_reaction(message, emoji) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_reaction/3`, but raises an exception if it fails."
      @spec create_reaction!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_id_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def create_reaction!(channel, message, emoji) do
        case Crux.Rest.create_reaction(channel, message, emoji) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `create_role/2`, but raises an exception if it fails."
      @spec create_role!(guild :: Crux.Rest.Util.guild_id_resolvable(), data :: guild_role_data()) ::
              Crux.Structs.Role.t() | no_return()
      Version.since("0.1.2")

      def create_role!(guild, data) do
        case Crux.Rest.create_role(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_all_reactions/2`, but raises an exception if it fails."
      @spec delete_all_reactions!(
              message :: Crux.Structs.Message.t(),
              emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_all_reactions!(message, emoji) do
        case Crux.Rest.delete_all_reactions(message, emoji) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_all_reactions/3`, but raises an exception if it fails."
      @spec delete_all_reactions!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_identifier_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_all_reactions!(channel, message, emoji) do
        case Crux.Rest.delete_all_reactions(channel, message, emoji) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_channel/2`, but raises an exception if it fails."
      @spec delete_channel!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              reason :: String.t()
            ) :: Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.0")

      def delete_channel!(channel, reason \\ nil) do
        case Crux.Rest.delete_channel(channel, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_channel_permissions/3`, but raises an exception if it fails."
      @spec delete_channel_permissions!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              target :: Crux.Rest.Util.overwrite_target_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_channel_permissions!(channel, target, reason \\ nil) do
        case Crux.Rest.delete_channel_permissions(channel, target, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_guild/1`, but raises an exception if it fails."
      @spec delete_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) :: :ok | no_return()
      Version.since("0.1.1")

      def delete_guild!(guild) do
        case Crux.Rest.delete_guild(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_guild_emoji/3`, but raises an exception if it fails."
      @spec delete_guild_emoji!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_guild_emoji!(guild, emoji, reason \\ nil) do
        case Crux.Rest.delete_guild_emoji(guild, emoji, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_guild_integration/2`, but raises an exception if it fails."
      @spec delete_guild_integration!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              integration_id :: snowflake()
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def delete_guild_integration!(guild, integration_id) do
        case Crux.Rest.delete_guild_integration(guild, integration_id) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_guild_role/3`, but raises an exception if it fails."
      @spec delete_guild_role!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              role :: Crux.Rest.Util.role_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def delete_guild_role!(guild, role, reason \\ nil) do
        case Crux.Rest.delete_guild_role(guild, role, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_invite/1`, but raises an exception if it fails."
      @spec delete_invite!(invite_or_code :: String.t() | Crux.Structs.Invite.t()) ::
              Crux.Structs.Invite.t() | no_return()
      Version.since("0.1.0")

      def delete_invite!(code) do
        case Crux.Rest.delete_invite(code) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_message/1`, but raises an exception if it fails."
      @spec delete_message!(message :: Crux.Structs.Message.t()) ::
              Crux.Structs.Message.t() | no_return()
      Version.since("0.1.0")

      def delete_message!(message) do
        case Crux.Rest.delete_message(message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_message/2`, but raises an exception if it fails."
      @spec delete_message!(
              channel_id :: Crux.Rest.Util.channel_id_resolvable(),
              message_id :: Crux.Rest.Util.message_id_resolvable()
            ) :: Crux.Structs.Message | no_return()
      Version.since("0.1.0")

      def delete_message!(channel, message) do
        case Crux.Rest.delete_message(channel, message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_messages/2`, but raises an exception if it fails."
      @spec delete_messages!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              messages :: [Crux.Rest.Util.message_id_resolvable()]
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_messages!(channel, messages) do
        case Crux.Rest.delete_messages(channel, messages) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_pinned_message/1`, but raises an exception if it fails."
      @spec delete_pinned_message!(message :: Crux.Structs.Message.t()) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_pinned_message!(message) do
        case Crux.Rest.delete_pinned_message(message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_pinned_message/2`, but raises an exception if it fails."
      @spec delete_pinned_message!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_pinned_message!(channel, message) do
        case Crux.Rest.delete_pinned_message(channel, message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_reaction/4`, but raises an exception if it fails."
      @spec delete_reaction!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_identifier_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def delete_reaction!(
            message_or_channel,
            emoji_or_message_id,
            emoji_or_maybe_user \\ "@me",
            mayber_user \\ "@me"
          ) do
        case Crux.Rest.delete_reaction(
               message_or_channel,
               emoji_or_message_id,
               emoji_or_maybe_user,
               mayber_user
             ) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `delete_webhook/2`, but raises an exception if it fails."
      @spec delete_webhook!(
              user :: Crux.Rest.Util.user_id_resolvable(),
              token :: String.t() | nil
            ) :: :ok | no_return()
      Version.since("0.1.7")

      def delete_webhook!(user, token \\ nil) do
        case Crux.Rest.delete_webhook(user, token) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `edit_channel_permissions/3`, but raises an exception if it fails."
      @spec edit_channel_permissions!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              target :: Crux.Rest.Util.overwrite_target_resolvable(),
              data :: edit_channel_permissions_data()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def edit_channel_permissions!(channel, target, data) do
        case Crux.Rest.edit_channel_permissions(channel, target, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `edit_message/2`, but raises an exception if it fails."
      @spec edit_message!(target :: Crux.Structs.Message.t(), args :: message_edit_data()) ::
              Crux.Structs.Message.t() | no_return()
      Version.since("0.1.0")

      def edit_message!(message, args) do
        case Crux.Rest.edit_message(message, args) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `edit_message/3`, but raises an exception if it fails."
      @spec edit_message!(
              channel_id :: Crux.Rest.Util.channel_id_resolvable(),
              message_id :: Crux.Rest.Util.message_id_resolvable(),
              args :: message_edit_data()
            ) :: Crux.Structs.Message.t() | no_return()
      Version.since("0.1.0")

      def edit_message!(channel, message_id, args) do
        case Crux.Rest.edit_message(channel, message_id, args) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_github_webhook/3`, but raises an exception if it fails."

      Version.since("0.1.7")

      def execute_github_webhook!(webhook, event, data) do
        case Crux.Rest.execute_github_webhook(webhook, event, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_github_webhook/5`, but raises an exception if it fails."
      @spec execute_github_webhook!(
              user :: Crux.Rest.Util.user_id_resolvable(),
              token :: String.t(),
              event :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | no_return()
      Version.since("0.1.7")

      def execute_github_webhook!(user, token, event, wait \\ false, data) do
        case Crux.Rest.execute_github_webhook(user, token, event, wait, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_slack_webhook/2`, but raises an exception if it fails."

      Version.since("0.1.7")

      def execute_slack_webhook!(webhook, data) do
        case Crux.Rest.execute_slack_webhook(webhook, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_slack_webhook/4`, but raises an exception if it fails."
      @spec execute_slack_webhook!(
              user :: Crux.Rest.Util.user_id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: term()
            ) :: :ok | no_return()
      Version.since("0.1.7")

      def execute_slack_webhook!(user, token, wait \\ false, data) do
        case Crux.Rest.execute_slack_webhook(user, token, wait, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_webhook/2`, but raises an exception if it fails."

      Version.since("0.1.7")

      def execute_webhook!(webhook, data) do
        case Crux.Rest.execute_webhook(webhook, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `execute_webhook/4`, but raises an exception if it fails."
      @spec execute_webhook!(
              user :: Crux.Rest.Util.user_id_resolvable(),
              token :: String.t(),
              wait :: boolean() | nil,
              data :: execute_webhook_options()
            ) :: :ok | no_return()
      Version.since("0.1.7")

      def execute_webhook!(user, token, wait \\ false, data) do
        case Crux.Rest.execute_webhook(user, token, wait, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `gateway/0`, but raises an exception if it fails."
      @spec gateway!() :: term() | no_return()
      Version.since("0.1.0")

      def gateway!() do
        case Crux.Rest.gateway() do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `gateway_bot/0`, but raises an exception if it fails."
      @spec gateway_bot!() :: term() | no_return()
      Version.since("0.1.0")

      def gateway_bot!() do
        case Crux.Rest.gateway_bot() do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_audit_logs/2`, but raises an exception if it fails."
      @spec get_audit_logs!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              options :: audit_log_options() | nil
            ) :: Crux.Structs.AuditLog.t() | no_return()
      Version.since("0.1.7")

      def get_audit_logs!(guild, options \\ []) do
        case Crux.Rest.get_audit_logs(guild, options) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_channel/1`, but raises an exception if it fails."
      @spec get_channel!(channel :: Crux.Rest.Util.resolve_channel_id()) ::
              Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.1")

      def get_channel!(channel) do
        case Crux.Rest.get_channel(channel) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_channel_invites/1`, but raises an exception if it fails."
      @spec get_channel_invites!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
              [Crux.Structs.Invite.t()] | no_return()
      Version.since("0.1.1")

      def get_channel_invites!(channel) do
        case Crux.Rest.get_channel_invites(channel) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_current_user_guilds/1`, but raises an exception if it fails."
      @spec get_current_user_guilds!(data :: get_current_user_guild_data()) ::
              [Crux.Structs.Guild.t()] | no_return()
      Version.since("0.1.4")

      def get_current_user_guilds!(data) do
        case Crux.Rest.get_current_user_guilds(data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild/1`, but raises an exception if it fails."
      @spec get_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              Crux.Structs.Guild.t() | no_return()
      Version.since("0.1.1")

      def get_guild!(guild) do
        case Crux.Rest.get_guild(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_ban/2`, but raises an exception if it fails."
      @spec get_guild_ban!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable()
            ) ::
              %{required(:user) => Crux.Structs.User.t(), required(:reason) => String.t() | nil}
              | no_return()
      Version.since("0.1.2")

      def get_guild_ban!(guild, user) do
        case Crux.Rest.get_guild_ban(guild, user) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_bans/1`, but raises an exception if it fails."
      @spec get_guild_bans!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              %{
                optional(snowflake()) => %{
                  required(:user) => Crux.Structs.User.t(),
                  required(:reason) => String.t() | nil
                }
              }
              | no_return()
      Version.since("0.1.2")

      def get_guild_bans!(guild) do
        case Crux.Rest.get_guild_bans(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_channels/1`, but raises an exception if it fails."
      @spec get_guild_channels!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              [Crux.Structs.Channel.t()] | no_return()
      Version.since("0.1.1")

      def get_guild_channels!(guild) do
        case Crux.Rest.get_guild_channels(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_embed/1`, but raises an exception if it fails."
      @spec get_guild_embed!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              term() | no_return()
      Version.since("0.1.2")

      def get_guild_embed!(guild) do
        case Crux.Rest.get_guild_embed(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_emoji/2`, but raises an exception if it fails."
      @spec get_guild_emoji!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_id_resolvable()
            ) :: Crux.Structs.Emoji | no_return()
      Version.since("0.1.1")

      def get_guild_emoji!(guild, emoji) do
        case Crux.Rest.get_guild_emoji(guild, emoji) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_integrations/1`, but raises an exception if it fails."
      @spec get_guild_integrations!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              list() | no_return()
      Version.since("0.1.2")

      def get_guild_integrations!(guild) do
        case Crux.Rest.get_guild_integrations(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_invites/1`, but raises an exception if it fails."
      @spec get_guild_invites!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              %{optional(String.t()) => Crux.Structs.Invite.t()} | no_return()
      Version.since("0.1.2")

      def get_guild_invites!(guild) do
        case Crux.Rest.get_guild_invites(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_member/2`, but raises an exception if it fails."
      @spec get_guild_member!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable()
            ) :: Crux.Structs.Member.t() | no_return()
      Version.since("0.1.0")

      def get_guild_member!(guild, user) do
        case Crux.Rest.get_guild_member(guild, user) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_prune_count/2`, but raises an exception if it fails."
      @spec get_guild_prune_count!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              days :: pos_integer()
            ) :: non_neg_integer() | no_return()
      Version.since("0.1.2")

      def get_guild_prune_count!(guild, days) do
        case Crux.Rest.get_guild_prune_count(guild, days) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_roles/1`, but raises an exception if it fails."
      @spec get_guild_roles!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              %{optional(snowflake()) => Crux.Structs.Role.t()} | no_return()
      Version.since("0.1.2")

      def get_guild_roles!(guild) do
        case Crux.Rest.get_guild_roles(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_vanity_url/1`, but raises an exception if it fails."
      @spec get_guild_vanity_url!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              String.t() | no_return()
      Version.since("0.1.2")

      def get_guild_vanity_url!(guild) do
        case Crux.Rest.get_guild_vanity_url(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_guild_voice_regions/1`, but raises an exception if it fails."
      @spec get_guild_voice_regions!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              term() | no_return()
      Version.since("0.1.2")

      def get_guild_voice_regions!(guild) do
        case Crux.Rest.get_guild_voice_regions(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_invite/1`, but raises an exception if it fails."
      @spec get_invite!(code :: String.t()) :: Crux.Structs.Invite.t() | no_return()
      Version.since("0.1.0")

      def get_invite!(code) do
        case Crux.Rest.get_invite(code) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_message/2`, but raises an exception if it fails."
      @spec get_message!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message_id :: Crux.Rest.Util.message_id_resolvable()
            ) :: Crux.Structs.Message | no_return()
      Version.since("0.1.0")

      def get_message!(channel, message) do
        case Crux.Rest.get_message(channel, message) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_messages/2`, but raises an exception if it fails."
      @spec get_messages!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              args :: get_messages_data()
            ) :: [Crux.Structs.Message.t()] | no_return()
      Version.since("0.1.0")

      def get_messages!(channel, args \\ []) do
        case Crux.Rest.get_messages(channel, args) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_pinned_messages/1`, but raises an exception if it fails."
      @spec get_pinned_messages!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
              [Crux.Structs.Message.t()] | no_return()
      Version.since("0.1.1")

      def get_pinned_messages!(channel) do
        case Crux.Rest.get_pinned_messages(channel) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_reactions/4`, but raises an exception if it fails."
      @spec get_reactions!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              message :: Crux.Rest.Util.message_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_identifier_resolvable(),
              args :: get_reactions_data()
            ) :: [Crux.Structs.User.t()] | no_return()
      Version.since("0.1.0")

      def get_reactions!(
            channel_or_message,
            emoji_or_message_id,
            emoji_or_maybe_data \\ [],
            maybe_data \\ []
          ) do
        case Crux.Rest.get_reactions(
               channel_or_message,
               emoji_or_message_id,
               emoji_or_maybe_data,
               maybe_data
             ) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_user/1`, but raises an exception if it fails."
      @spec get_user!(user :: Crux.Rest.Util.user_id_resolvable() | String.t()) ::
              Crux.Structs.User.t() | no_return()
      Version.since("0.1.4")

      def get_user!(user) do
        case Crux.Rest.get_user(user) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_user_dms/0`, but raises an exception if it fails."
      @spec get_user_dms!() :: [Crux.Structs.Channel.t()] | no_return()
      Version.since("0.1.4")

      def get_user_dms!() do
        case Crux.Rest.get_user_dms() do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `get_webhook/2`, but raises an exception if it fails."
      @spec get_webhook!(user :: Crux.Rest.Util.user_id_resolvable(), token :: String.t() | nil) ::
              [Crux.Structs.Webhook.t()] | no_return()
      Version.since("0.1.7")

      def get_webhook!(user, token \\ nil) do
        case Crux.Rest.get_webhook(user, token) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `leave_guild/1`, but raises an exception if it fails."
      @spec leave_guild!(guild :: Crux.Rest.Util.guild_id_resolvable()) :: :ok | no_return()
      Version.since("0.1.4")

      def leave_guild!(guild) do
        case Crux.Rest.leave_guild(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `list_channel_webhooks/1`, but raises an exception if it fails."
      @spec list_channel_webhooks!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
              [Crux.Structs.Webhook.t()] | no_return()
      Version.since("0.1.7")

      def list_channel_webhooks!(channel) do
        case Crux.Rest.list_channel_webhooks(channel) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `list_guild_emojis/1`, but raises an exception if it fails."
      @spec list_guild_emojis!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              [Crux.Structs.Emoji.t()] | no_return()
      Version.since("0.1.1")

      def list_guild_emojis!(guild) do
        case Crux.Rest.list_guild_emojis(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `list_guild_members/2`, but raises an exception if it fails."
      @spec list_guild_members!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              options :: list_guild_members_options()
            ) :: [Crux.Structs.Member.t()] | no_return()
      Version.since("0.1.0")

      def list_guild_members!(guild, options \\ []) do
        case Crux.Rest.list_guild_members(guild, options) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `list_guild_webhooks/1`, but raises an exception if it fails."
      @spec list_guild_webhooks!(guild :: Crux.Rest.Util.guild_id_resolvable()) ::
              [Crux.Structs.Webhook.t()] | no_return()
      Version.since("0.1.7")

      def list_guild_webhooks!(guild) do
        case Crux.Rest.list_guild_webhooks(guild) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_channel/2`, but raises an exception if it fails."
      @spec modify_channel!(
              channel :: Crux.Rest.Util.channel_id_resolvable(),
              data :: modify_channel_data()
            ) :: Crux.Structs.Channel.t() | no_return()
      Version.since("0.1.0")

      def modify_channel!(channel, data) do
        case Crux.Rest.modify_channel(channel, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_current_user/1`, but raises an exception if it fails."
      @spec modify_current_user!(data :: modify_current_user_data()) ::
              Crux.Structs.User.t() | no_return()
      Version.since("0.1.4")

      def modify_current_user!(data) do
        case Crux.Rest.modify_current_user(data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_current_users_nick/3`, but raises an exception if it fails."
      @spec modify_current_users_nick!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              nick :: String.t(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def modify_current_users_nick!(guild, nick, reason \\ nil) do
        case Crux.Rest.modify_current_users_nick(guild, nick, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild/2`, but raises an exception if it fails."
      @spec modify_guild!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data :: modify_guild_data()
            ) :: Crux.Structs.Guild.t() | no_return()
      Version.since("0.1.0")

      def modify_guild!(guild, data) do
        case Crux.Rest.modify_guild(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_channel_positions/2`, but raises an exception if it fails."
      @spec modify_guild_channel_positions!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              channels :: [modify_guild_channel_positions_data_entry()]
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def modify_guild_channel_positions!(guild, channels) do
        case Crux.Rest.modify_guild_channel_positions(guild, channels) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_embed/2`, but raises an exception if it fails."
      @spec modify_guild_embed!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data ::
                %{optional(:enabled) => boolean(), optional(:channel_id) => snowflake()}
                | [{:enabled, boolean()} | {:channel_id, snowflake()}]
            ) :: term() | no_return()
      Version.since("0.1.2")

      def modify_guild_embed!(guild, data) do
        case Crux.Rest.modify_guild_embed(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_emoji/3`, but raises an exception if it fails."
      @spec modify_guild_emoji!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              emoji :: Crux.Rest.Util.emoji_id_resolvable(),
              data :: modify_guild_emoji_data()
            ) :: Crux.Structs.Emoji | no_return()
      Version.since("0.1.0")

      def modify_guild_emoji!(guild, emoji, data) do
        case Crux.Rest.modify_guild_emoji(guild, emoji, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_integration/3`, but raises an exception if it fails."
      @spec modify_guild_integration!(
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
      Version.since("0.1.2")

      def modify_guild_integration!(guild, integration_id, data) do
        case Crux.Rest.modify_guild_integration(guild, integration_id, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_member/3`, but raises an exception if it fails."
      @spec modify_guild_member!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              member :: Crux.Rest.Util.user_id_resolvable(),
              data :: modify_guild_member_data()
            ) :: :ok | no_return()
      Version.since("0.1.0")

      def modify_guild_member!(guild, member, data) do
        case Crux.Rest.modify_guild_member(guild, member, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_role/3`, but raises an exception if it fails."
      @spec modify_guild_role!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              role :: Crux.Rest.Util.role_id_resolvable(),
              data :: guild_role_data()
            ) :: Crux.Structs.Role.t() | no_return()
      Version.since("0.1.2")

      def modify_guild_role!(guild, role, data) do
        case Crux.Rest.modify_guild_role(guild, role, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `modify_guild_role_positions/2`, but raises an exception if it fails."
      @spec modify_guild_role_positions!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              data :: Crux.Rest.Util.modify_guild_role_positions_data()
            ) :: %{optional(snowflake()) => Crux.Structs.Role.t()} | no_return()
      Version.since("0.1.2")

      def modify_guild_role_positions!(guild, data) do
        case Crux.Rest.modify_guild_role_positions(guild, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `remove_guild_ban/3`, but raises an exception if it fails."
      @spec remove_guild_ban!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              user :: Crux.Rest.Util.user_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def remove_guild_ban!(guild, user, reason \\ nil) do
        case Crux.Rest.remove_guild_ban(guild, user, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `remove_guild_member_role/4`, but raises an exception if it fails."
      @spec remove_guild_member_role!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              member :: Crux.Rest.Util.user_id_resolvable(),
              role :: Crux.Rest.Util.role_id_resolvable(),
              reason :: String.t()
            ) :: :ok | no_return()
      Version.since("0.1.1")

      def remove_guild_member_role!(guild, member, role, reason \\ nil) do
        case Crux.Rest.remove_guild_member_role(guild, member, role, reason) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `sync_guild_integration/2`, but raises an exception if it fails."
      @spec sync_guild_integration!(
              guild :: Crux.Rest.Util.guild_id_resolvable(),
              integration_id :: snowflake()
            ) :: :ok | no_return()
      Version.since("0.1.2")

      def sync_guild_integration!(guild, integration_id) do
        case Crux.Rest.sync_guild_integration(guild, integration_id) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `trigger_typing/1`, but raises an exception if it fails."
      @spec trigger_typing!(channel :: Crux.Rest.Util.channel_id_resolvable()) ::
              :ok | no_return()
      Version.since("0.1.1")

      def trigger_typing!(channel) do
        case Crux.Rest.trigger_typing(channel) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end

      @doc "The same as `update_webhook/3`, but raises an exception if it fails."
      @spec update_webhook!(
              user :: Crux.Rest.Util.user_id_resolvable(),
              token :: String.t() | nil,
              data ::
                %{
                  optional(:name) => String.t(),
                  optional(:avatar) => String.t(),
                  optional(:channel_id) => snowflake()
                }
                | [{:name, String.t()} | {:avatar, String.t()} | {:channel_id, snowflake()}]
            ) :: Crux.Structs.Webhook.t() | no_return()
      Version.since("0.1.7")

      def update_webhook!(user, token \\ nil, data) do
        case Crux.Rest.update_webhook(user, token, data) do
          :ok ->
            :ok

          {:ok, res} ->
            res

          {:error, error} ->
            raise error
        end
      end
    end
  end
end
