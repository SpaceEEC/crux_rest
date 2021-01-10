# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule Crux.Rest.Impl do
  @moduledoc """
    TODO: Write me
  """
  @moduledoc since: "0.3.0"

  ###
  # Conventions
  ###

  # The paramter for the options is always called `opts`
  # Later when transforming the new parameter is called:
  # - When used as a request body: `data`
  # - When used as a query string: `params`

  alias Crux.Structs

  alias Crux.Structs.{
    AuditLog,
    Channel,
    Emoji,
    Guild,
    Integration,
    Invite,
    Member,
    Message,
    Permissions,
    Role,
    Snowflake,
    User,
    Util,
    VoiceRegion,
    Webhook
  }

  alias Crux.Rest.{Endpoints, Request}
  alias Crux.Rest.Impl.Resolver

  def get_audit_log(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    params =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:user_id, User)
      |> Resolver.resolve_custom(:before, &Snowflake.to_snowflake/1)
      |> Map.to_list()

    path = Endpoints.guilds_audit_logs(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(AuditLog)
  end

  def get_channel(channel) do
    channel_id = Resolver.resolve!(channel, Channel)
    path = Endpoints.channels(channel_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Channel)
  end

  def modify_channel(channel, opts \\ %{}) do
    channel_id = Resolver.resolve!(channel, Channel)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:parent_id, Channel)
      |> Resolver.resolve_custom(
        :permission_overwrites,
        &Resolver.resolve_permission_overwrites/1
      )
      |> Map.pop(:reason)

    path = Endpoints.channels(channel_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Channel)
  end

  def delete_channel(channel, reason \\ nil) do
    channel_id = Resolver.resolve!(channel, Channel)

    path = Endpoints.channels(channel_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
    |> Request.put_transform(Channel)
  end

  def get_messages(channel, opts \\ %{}) do
    channel_id = Resolver.resolve!(channel, Channel)

    params =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:around, Message)
      |> Resolver.resolve_option(:before, Message)
      |> Resolver.resolve_option(:after, Message)
      |> Map.to_list()

    path = Endpoints.channels_messages(channel_id)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(Message)
  end

  def get_message(%{channel_id: channel_id, id: message_id}) do
    get_message(channel_id, message_id)
  end

  def get_message(channel, message) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    path = Endpoints.channels_messages(channel_id, message_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Message)
  end

  def create_message(channel, opts)
      when not is_map(opts) do
    create_message(channel, Map.new(opts))
  end

  def create_message(channel, opts) do
    channel_id = Resolver.resolve!(channel, Channel)

    {data, headers} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:allowed_mentions, &Resolver.resolve_allowed_mentions/1)
      |> Resolver.resolve_custom(:message_reference, &Resolver.resolve_message_reference/1)
      |> Resolver.resolve_files()

    path = Endpoints.channels_messages(channel_id)

    :post
    |> Request.new(path, data)
    |> Request.put_headers(headers)
    |> Request.put_transform(Message)
  end

  def create_reaction(%{channel_id: channel_id, id: message_id}, emoji) do
    create_reaction(channel_id, message_id, emoji)
  end

  def create_reaction(channel, message, emoji) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)
    emoji_identifier = Emoji.to_identifier(emoji)

    path = Endpoints.channels_messages_reactions_me(channel_id, message_id, emoji_identifier)

    Request.new(:put, path)
  end

  def delete_user_reaction(%{channel_id: channel_id, id: message_id}, emoji, user) do
    delete_user_reaction(channel_id, message_id, emoji, user)
  end

  def delete_user_reaction(channel, message, emoji, user) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)
    emoji_identifier = Emoji.to_identifier(emoji)
    user_id = if user == "@me", do: user, else: Resolver.resolve!(user, User)

    path =
      Endpoints.channels_messages_reactions(
        channel_id,
        message_id,
        emoji_identifier,
        user_id
      )

    Request.new(:delete, path)
  end

  def get_reactions(
        channel_or_message,
        message_or_emoji,
        emoji_or_opts \\ %{},
        opts_or_ignore \\ %{}
      )

  def get_reactions(%{channel_id: channel_id, id: message_id}, emoji, opts, ignore)
      when map_size(ignore) == 0 do
    get_reactions(channel_id, message_id, emoji, opts)
  end

  def get_reactions(channel, message, emoji, opts) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)
    emoji_identifier = Emoji.to_identifier(emoji)

    params =
      opts
      |> Map.new()
      |> Resolver.resolve_option!(:before, User)
      |> Resolver.resolve_option!(:after, User)
      |> Map.to_list()

    path = Endpoints.channels_messages_reactions(channel_id, message_id, emoji_identifier)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(User)
  end

  def delete_all_reactions(%{channel_id: channel_id, id: message_id}) do
    delete_all_reactions(channel_id, message_id)
  end

  def delete_all_reactions(channel, message) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    path = Endpoints.channels_messages_reactions(channel_id, message_id)

    Request.new(:delete, path)
  end

  def delete_all_reactions_for_emoji(%{channel_id: channel_id, id: message_id}, emoji) do
    delete_all_reactions_for_emoji(channel_id, message_id, emoji)
  end

  def delete_all_reactions_for_emoji(channel, message, emoji) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)
    emoji_identifier = Emoji.to_identifier(emoji)

    path = Endpoints.channels_messages_reactions(channel_id, message_id, emoji_identifier)

    Request.new(:delete, path)
  end

  def modify_message(
        message_or_channel,
        message_or_opts \\ %{},
        opts_or_ignroe \\ %{}
      )

  def modify_message(%{channel_id: channel_id, id: message_id}, opts, ignore)
      when map_size(ignore) == 0 do
    modify_message(channel_id, message_id, opts)
  end

  def modify_message(channel, message, opts) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    data =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:allowed_mentions, &Resolver.resolve_allowed_mentions/1)

    path = Endpoints.channels_messages(channel_id, message_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_transform(Message)
  end

  def delete_message(%{channel_id: channel_id, id: message_id}) do
    delete_message(channel_id, message_id)
  end

  def delete_message(channel, message) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    path = Endpoints.channels_messages(channel_id, message_id)

    :delete
    |> Request.new(path)
    # Separate route as this is an exception
    # See the first info box here:
    # https://discordapp.com/developers/docs/topics/rate-limits#rate-limits
    |> Map.update!(:route, &("DELETE:" <> &1))
  end

  def delete_messages(channel, messages) do
    channel_id = Resolver.resolve!(channel, Channel)

    data = %{messages: Enum.map(messages, &Resolver.resolve!(&1, Message))}

    path = Endpoints.channels_messages_bulk_delete(channel_id)

    Request.new(:delete, path, data)
  end

  def modify_channel_overwrite(channel, overwrite, reason \\ nil) do
    channel_id = Resolver.resolve!(channel, Channel)
    %{id: overwrite_id} = overwrite = Resolver.resolve_overwrite(overwrite)

    path = Endpoints.channels_permissions(channel_id, overwrite_id)

    :put
    |> Request.new(path, overwrite)
    |> Request.put_reason(reason)
  end

  def get_channel_invites(channel) do
    channel_id = Resolver.resolve!(channel, Channel)

    path = Endpoints.channels_invites(channel_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Invite, :code))
  end

  def create_invite(channel, opts \\ %{}) do
    channel_id = Resolver.resolve!(channel, Channel)

    {reason, data} =
      opts
      |> Map.new()
      |> Map.pop(:reason)

    path = Endpoints.channels_invites(channel_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Invite)
  end

  def delete_channel_overwrite(channel, overwrite, reason \\ nil) do
    channel_id = Resolver.resolve!(channel, Channel)

    overwrite_id =
      Structs.resolve_id(overwrite, User) || Structs.resolve_id(overwrite, Role) ||
        raise ArgumentError, """
        Could not resolve the overwrite id of the given data

        Received #{inspect(overwrite)}
        """

    path = Endpoints.channels_permissions(channel_id, overwrite_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def create_typing_indicator(channel) do
    channel_id = Resolver.resolve!(channel, Channel)

    path = Endpoints.channels_typing(channel_id)

    Request.new(:post, path)
  end

  def get_pinned_messages(channel) do
    channel_id = Resolver.resolve!(channel, Channel)

    path = Endpoints.channels_pins(channel_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Message))
  end

  def create_pinned_message(
        message_or_channel,
        message_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def create_pinned_message(
        %{channel_id: channel_id, id: message_id},
        reason,
        nil
      ) do
    create_pinned_message(channel_id, message_id, reason)
  end

  def create_pinned_message(channel, message, reason) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    path = Endpoints.channels_pins(channel_id, message_id)

    :put
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def delete_pinned_message(
        message_or_channel,
        message_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def delete_pinned_message(
        %{channel_id: channel_id, id: message_id},
        reason,
        nil
      ) do
    delete_pinned_message(channel_id, message_id, reason)
  end

  def delete_pinned_message(channel, message, reason) do
    channel_id = Resolver.resolve!(channel, Channel)
    message_id = Resolver.resolve!(message, Message)

    path = Endpoints.channels_pins(channel_id, message_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def get_emojis(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_emojis(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Emoji))
  end

  def get_emoji(guild, emoji) do
    guild_id = Resolver.resolve!(guild, Guild)
    emoji_id = Resolver.resolve!(emoji, Emoji)

    path = Endpoints.guilds_emojis(guild_id, emoji_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Emoji)
  end

  def create_emoji(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:roles, &Resolver.resolve_list!(&1, Role))
      |> Resolver.resolve_custom(:image, &Resolver.resolve_image/1)
      |> Map.pop(:reason)

    path = Endpoints.guilds_emojis(guild_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Emoji)
  end

  def modify_emoji(guild, emoji, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)
    emoji_id = Resolver.resolve!(emoji, Emoji)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:roles, &Resolver.resolve_list!(&1, Role))
      |> Map.pop(:reason)

    path = Endpoints.guilds_emojis(guild_id, emoji_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Emoji)
  end

  def delete_emoji(guild, emoji, reason \\ nil) do
    guild_id = Resolver.resolve!(guild, Guild)
    emoji_id = Resolver.resolve!(emoji, Emoji)

    path = Endpoints.guilds_emojis(guild_id, emoji_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def create_guild(opts \\ %{}) do
    data = Map.new(opts)

    path = Endpoints.guilds()

    :post
    |> Request.new(path, data)
    |> Request.put_transform(Guild)
  end

  def get_guild(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Guild)
  end

  def get_guild_preview(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_preview(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(GuildPreview)
  end

  def modify_guild(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:icon, &Resolver.resolve_image/1)
      |> Resolver.resolve_custom(:splash, &Resolver.resolve_image/1)
      |> Resolver.resolve_custom(:banner, &Resolver.resolve_image/1)
      |> Resolver.resolve_option(:afk_channel_id, Channel)
      |> Resolver.resolve_option(:system_channel_id, Channel)
      |> Resolver.resolve_option(:rules_channel_id, Channel)
      |> Resolver.resolve_option(:public_update_channel_id, Channel)
      |> Map.pop(:reason)

    path = Endpoints.guilds(guild_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Guild)
  end

  def delete_guild(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds(guild_id)

    Request.new(:delete, path)
  end

  def get_channels(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_channels(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Channel))
  end

  def create_channel(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:parent_id, Channel)
      |> Resolver.resolve_custom(
        :permission_overwrites,
        &Resolver.resolve_permission_overwrites/1
      )
      |> Map.pop(:reason)

    path = Endpoints.guilds_channels(guild_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Channel)
  end

  def modify_channel_positions(guild, opts \\ []) do
    guild_id = Resolver.resolve!(guild, Guild)

    data = Enum.map(opts, &Resolver.resolve_option!(&1, :id, Channel))

    path = Endpoints.guilds_channels(guild_id)

    Request.new(:patch, path, data)
  end

  def get_member(%{guild_id: guild_id, user: user_id}) do
    get_member(guild_id, user_id)
  end

  def get_member(guild, user) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.guilds_members(guild_id, user_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Member)
  end

  def get_members(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    params =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:after, User)
      |> Map.to_list()

    path = Endpoints.guilds_members(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(to_map(Member, :user))
  end

  def create_member(guild, user, opts) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    data =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:roles, &Resolver.resolve_list!(&1, Role))

    path = Endpoints.guilds_members(guild_id, user_id)

    :put
    |> Request.new(path, data)
    |> Request.put_transform(Member)
  end

  def modify_member(
        guild_or_member,
        user_or_opts \\ %{},
        opts_or_ignore \\ %{}
      )

  def modify_member(%{guild_id: guild_id, id: user_id}, opts, ignore)
      when map_size(ignore) == 0 do
    modify_member(guild_id, user_id, opts)
  end

  def modify_member(guild, user, opts) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:roles, &Resolver.resolve_list!(&1, Role))
      |> Resolver.resolve_option(:channel_id, Channel)
      |> Map.pop(:reason)

    path = Endpoints.guilds_members(guild_id, user_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
  end

  def modify_current_user_nick(guild, nick, reason \\ nil) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_members_me_nick(guild_id)

    :patch
    |> Request.new(path, %{nick: nick})
    |> Request.put_reason(reason)
    |> Request.put_transform(&Util.atomify/1)
  end

  def create_member_role(
        guild_or_member,
        user_or_role,
        role_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def create_member_role(%{guild_id: guild_id, id: user_id}, role, reason, nil) do
    create_member_role(guild_id, user_id, role, reason)
  end

  def create_member_role(guild, user, role, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)
    role_id = Resolver.resolve!(role, Role)

    path = Endpoints.guilds_members_roles(guild_id, user_id, role_id)

    :put
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def delete_member_role(
        guild_or_member,
        user_or_role,
        role_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def delete_member_role(%{guild_id: guild_id, id: user_id}, role, reason, nil) do
    delete_member_role(guild_id, user_id, role, reason)
  end

  def delete_member_role(guild, user, role, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)
    role_id = Resolver.resolve!(role, Role)

    path = Endpoints.guilds_members_roles(guild_id, user_id, role_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def delete_member(
        guild_or_member,
        user_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def delete_member(%{guild_id: guild_id, id: user_id}, reason, nil) do
    delete_member(guild_id, user_id, reason)
  end

  def delete_member(guild, user, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.guilds_members(guild_id, user_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def get_bans(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_bans(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(
      &Map.new(&1, fn raw ->
        guild_ban =
          raw
          |> Util.atomify()
          |> Map.update!(:user, fn user -> Structs.create(user, User) end)
          |> Map.put_new(:reason, nil)

        {guild_ban.user.id, guild_ban}
      end)
    )
  end

  def get_ban(%{guild_id: guild_id, user: user_id}) do
    get_ban(guild_id, user_id)
  end

  def get_ban(guild, user) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.guilds_bans(guild_id, user_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(fn raw ->
      raw
      |> Util.atomify()
      |> Map.update!(:user, fn user -> Structs.create(user, User) end)
      |> Map.put_new(:reason, nil)
    end)
  end

  def create_ban(
        guild_or_member,
        user_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def create_ban(%{guild_id: guild_id, id: user_id}, reason, nil) do
    create_ban(guild_id, user_id, reason)
  end

  def create_ban(guild, user, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.guilds_bans(guild_id, user_id)

    :put
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def delete_ban(
        guild_or_member,
        user_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def delete_ban(%{guild_id: guild_id, id: user_id}, reason, nil) do
    delete_ban(guild_id, user_id, reason)
  end

  def delete_ban(guild, user, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.guilds_bans(guild_id, user_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def get_roles(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_roles(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Role))
  end

  def create_role(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:permissions, &Permissions.resolve/1)
      |> Map.pop(:reason)

    path = Endpoints.guilds_roles(guild_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Role)
  end

  def modify_role_positions(guild, opts \\ []) do
    guild_id = Resolver.resolve!(guild, Guild)

    data = Enum.map(opts, &Resolver.resolve_option!(&1, :id, Role))

    path = Endpoints.guilds_roles(guild_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_transform(to_map(Role))
  end

  def modify_role(
        role_or_guild,
        role_or_opts \\ %{},
        opts_or_ignore \\ %{}
      )

  def modify_role(%{guild_id: guild_id, id: role_id}, opts, ignore)
      when map_size(ignore) == 0 do
    modify_role(guild_id, role_id, opts)
  end

  def modify_role(guild, role, opts) do
    guild_id = Resolver.resolve!(guild, Guild)
    role_id = Resolver.resolve!(role, Role)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:permissions, &Permissions.resolve/1)
      |> Map.pop(:reason)

    path = Endpoints.guilds_roles(guild_id, role_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Role)
  end

  def delete_role(
        role_or_guild,
        role_or_reason \\ nil,
        reason_or_ignore \\ nil
      )

  def delete_role(%{guild_id: guild_id, id: role_id}, reason, nil) do
    delete_role(guild_id, role_id, reason)
  end

  def delete_role(guild, role, reason) do
    guild_id = Resolver.resolve!(guild, Guild)
    role_id = Resolver.resolve!(role, Role)

    path = Endpoints.guilds_roles(guild_id, role_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
    |> Request.put_transform(Role)
  end

  def get_prune_count(guild, opts) do
    guild_id = Resolver.resolve!(guild, Guild)

    params = Enum.to_list(opts)

    path = Endpoints.guilds_prune(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(&Util.atomify/1)
  end

  def create_prune(guild, opts) do
    guild_id = Resolver.resolve!(guild, Guild)

    params = Enum.to_list(opts)

    path = Endpoints.guilds_prune(guild_id)

    :post
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(&Util.atomify/1)
  end

  def get_voice_regions(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_regions(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(VoiceRegion))
  end

  def get_guild_invites(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_invites(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Invite, :code))
  end

  def get_integrations(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_integrations(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Integration))
  end

  def create_integration(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:id, &Snowflake.to_snowflake/1)
      |> Map.pop(:reason)

    path = Endpoints.guilds_integrations(guild_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
  end

  def modify_integration(guild, integration, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)
    integration_id = Resolver.resolve!(integration, Integration)

    {reason, data} =
      opts
      |> Map.new()
      |> Map.pop(:reason)

    path = Endpoints.guilds_integrations(guild_id, integration_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
  end

  def delete_integration(guild, integration, reason \\ nil) do
    guild_id = Resolver.resolve!(guild, Guild)
    integration_id = Resolver.resolve!(integration, Integration)

    path = Endpoints.guilds_integrations(guild_id, integration_id)

    :patch
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def create_integration_sync(guild, integration) do
    guild_id = Resolver.resolve!(guild, Guild)
    integration_id = Resolver.resolve!(integration, Integration)

    path = Endpoints.guilds_integrations_sync(guild_id, integration_id)

    Request.new(:post, path)
  end

  def get_guild_embed(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_embed(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(fn guild_embed ->
      guild_embed
      |> Util.atomify()
      |> Resolver.resolve_option(:channel_id, Channel)
    end)
  end

  def modify_guild_embed(guild, opts \\ %{}) do
    guild_id = Resolver.resolve!(guild, Guild)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:channel_id, Channel)
      |> Map.pop(:reason)

    path = Endpoints.guilds_embed(guild_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(fn guild_embed ->
      guild_embed
      |> Util.atomify()
      |> Resolver.resolve_option(:channel_id, Channel)
    end)
  end

  def get_vanity_url(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_vanity_url(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(&Util.atomify/1)
  end

  def get_invite(code, opts) do
    params = Enum.to_list(opts)

    path = Endpoints.invites(code)

    :get
    |> Request.new(path)
    |> Request.put_params(params)
    |> Request.put_transform(Invite)
  end

  def delete_invite(code, reason \\ nil) do
    path = Endpoints.invites(code)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
    |> Request.put_transform(Invite)
  end

  def get_current_user() do
    path = Endpoints.users_me()

    :get
    |> Request.new(path)
    |> Request.put_transform(User)
  end

  def get_user(user) do
    user_id = Resolver.resolve!(user, User)

    path = Endpoints.users(user_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(User)
  end

  def modify_current_user(opts) do
    data =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:avatar, &Resolver.resolve_image/1)

    path = Endpoints.users_me()

    :patch
    |> Request.new(path, data)
    |> Request.put_transform(User)
  end

  def get_current_user_guilds(opts) do
    data =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:before, Guild)
      |> Resolver.resolve_option(:after, Guild)
      |> Map.to_list()

    path = Endpoints.users_me_guilds()

    :get
    |> Request.new(path, data)
    |> Request.put_transform(to_map(Guild))
  end

  def leave_guild(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.users_me_guilds(guild_id)

    Request.new(:delete, path)
  end

  def create_dm(user) do
    user_id = Resolver.resolve!(user, User)

    data = %{recipient_id: user_id}

    path = Endpoints.users_me_channels()

    :post
    |> Request.new(path, data)
    |> Request.put_transform(Channel)
  end

  def get_voice_regions() do
    path = Endpoints.voice_regions()

    :get
    |> Request.new(path)
    |> Request.put_transform(VoiceRegion)
  end

  def create_webhook(channel, opts) do
    channel_id = Resolver.resolve!(channel, Channel)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_custom(:avatar, &Resolver.resolve_image/1)
      |> Map.pop(:reason)

    path = Endpoints.channels_webhooks(channel_id)

    :post
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Webhook)
  end

  def get_channel_webhooks(channel) do
    channel_id = Resolver.resolve!(channel, Channel)

    path = Endpoints.channels_webhooks(channel_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Webhook))
  end

  def get_guild_webhooks(guild) do
    guild_id = Resolver.resolve!(guild, Guild)

    path = Endpoints.guilds_webhooks(guild_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(to_map(Webhook))
  end

  def get_webhook(%{id: webhook_id, token: token})
      when is_binary(token) do
    get_webhook(webhook_id, token)
  end

  def get_webhook(webhook) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    path = Endpoints.webhooks(webhook_id)

    :get
    |> Request.new(path)
    |> Request.put_transform(Webhook)
  end

  def get_webhook(webhook, token) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    path = Endpoints.webhooks(webhook_id, token)

    :get
    |> Request.new(path)
    |> Request.put_auth(false)
    |> Request.put_transform(Webhook)
  end

  def modify_webhook(%{id: webhook_id, token: token}, opts)
      when is_binary(token) do
    modify_webhook(webhook_id, token, opts)
  end

  def modify_webhook(webhook, opts) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:channel_id, Channel)
      |> Resolver.resolve_custom(:avatar, &Resolver.resolve_image/1)
      |> Map.pop(:reason)

    path = Endpoints.webhooks(webhook_id)

    :patch
    |> Request.new(path, data)
    |> Request.put_reason(reason)
    |> Request.put_transform(Webhook)
  end

  def modify_webhook(webhook, token, opts) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    {reason, data} =
      opts
      |> Map.new()
      |> Resolver.resolve_option(:channel_id, Channel)
      |> Map.pop(:reason)

    path = Endpoints.webhooks(webhook_id, token)

    :patch
    |> Request.new(path, data)
    |> Request.put_auth(false)
    |> Request.put_reason(reason)
    |> Request.put_transform(Webhook)
  end

  def delete_webhook(webhook, opts_or_token \\ %{})

  def delete_webhook(webhook, token)
      when is_binary(token) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    path = Endpoints.webhooks(webhook_id, token)

    :delete
    |> Request.new(path)
    |> Request.put_auth(false)
  end

  def delete_webhook(webhook, opts) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    reason = opts |> Map.new() |> Map.get(:reason)

    path = Endpoints.webhooks(webhook_id)

    :delete
    |> Request.new(path)
    |> Request.put_reason(reason)
  end

  def create_webhook_message(%{token: token, id: id}, opts) do
    create_webhook_message(id, token, opts)
  end

  def create_webhook_message(webhook, token, opts)
      when not is_map(opts) do
    create_webhook_message(webhook, token, Map.new(opts))
  end

  def create_webhook_message(webhook, token, opts)
      when is_binary(token) do
    webhook_id = Resolver.resolve!(webhook, Webhook)

    type = Map.get(opts, :type, :discord)
    wait = Map.get(opts, :wait, true)
    event = Map.get(opts, :event)

    {data, headers} =
      opts
      |> Map.drop(~w/type wait event/)
      |> Resolver.resolve_custom(:allowed_mentions, &Resolver.resolve_allowed_mentions/1)
      |> Resolver.resolve_files()

    path = webhook_path_from_type(type, webhook_id, token)

    headers2 =
      if type == :github and event do
        [{"x-github-event", event} | headers]
      else
        headers
      end

    :post
    |> Request.new(path, data)
    |> Request.put_params(wait: wait)
    |> Request.put_headers(headers2)
  end

  defp webhook_path_from_type(:github, webhook_id, token) do
    Endpoints.webhooks_github(webhook_id, token)
  end

  defp webhook_path_from_type(:slack, webhook_id, token) do
    Endpoints.webhooks_slack(webhook_id, token)
  end

  defp webhook_path_from_type(discord, webhook_id, token)
       when discord in [nil, :discord] do
    Endpoints.webhooks(webhook_id, token)
  end

  def get_gateway() do
    path = Endpoints.gateway()

    :get
    |> Request.new(path)
    |> Request.put_auth(false)
    |> Request.put_transform(&Util.atomify/1)
  end

  def get_gateway_bot() do
    path = Endpoints.gateway_bot()

    :get
    |> Request.new(path)
    |> Request.put_transform(&Util.atomify/1)
  end

  # credo:disable-for-lines:35
  @spec get_current_application :: Crux.Rest.Request.t()
  def get_current_application() do
    path = Endpoints.oauth2_applictions_me()

    :get
    |> Request.new(path)
    |> Request.put_transform(fn application ->
      application
      |> Util.atomify()
      |> Map.update!(:id, &Snowflake.to_snowflake/1)
      |> Resolver.resolve_custom(:guild_id, &Snowflake.to_snowflake/1)
      |> Resolver.resolve_custom(:primary_sku_id, &Snowflake.to_snowflake/1)
      |> Map.update!(:owner, &Structs.create(&1, User))
      |> update_in([:team, :id], &Snowflake.to_snowflake/1)
      |> update_in([:team, :owner_user_id], &Snowflake.to_snowflake/1)
      |> update_in(
        [:team, :members],
        fn members ->
          Map.new(members, fn member ->
            %{user: %{id: id}} =
              member =
              member
              |> Map.update!(:team_id, &Snowflake.to_snowflake/1)
              |> Map.update!(:user, &Structs.create(&1, User))

            {id, member}
          end)
        end
      )
    end)
  end

  defp to_map(target, key \\ :id) do
    fn data ->
      data
      |> Structs.create(target)
      |> Map.new(fn %{^key => key} = struct ->
        {key, struct}
      end)
    end
  end
end
