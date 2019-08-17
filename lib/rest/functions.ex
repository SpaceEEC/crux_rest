defmodule Crux.Rest.Functions do
  @moduledoc """
    Module with functions to create `Crux.Rest.Request` which can be executed.

    There are no bangified functions here as no requests to Discord are actually made.

    * All functions return a `Crux.Rest.Request`.
    * Parameters are as described in `Crux.Rest` behaviour.
  """

  @behaviour Crux.Rest

  alias Crux.Rest.{Endpoints, Request, Util}

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

  alias Crux.Structs

  ### Message

  @impl true
  def create_message(channel_or_message, data) do
    channel_id = Util.resolve_channel_id(channel_or_message)

    path = Endpoints.channel_messages(channel_id)

    {data, disposition} =
      data
      |> Map.new()
      |> Util.resolve_multipart()

    :post
    |> Request.new(path, data)
    |> Request.set_headers(disposition)
    |> Request.set_transform(Message)
  end

  @impl true
  def get_message(message_or_channel, data_or_channel \\ [], data \\ [])

  def get_message(%{channel_id: channel_id, id: message_id}, data, _) do
    get_message(channel_id, message_id, data)
  end

  def get_message(channel, message, data) do
    data = Keyword.new(data)

    :get
    |> common_message(
      channel,
      message,
      &Endpoints.channel_messages/2,
      &Request.new(&1, &2)
    )
    |> Request.set_params(data)
    |> Request.set_transform(Message)
  end

  @impl true
  def get_messages(channel, data) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_messages(channel_id)
    data = Keyword.new(data)

    :get
    |> Request.new(path)
    |> Request.set_params(data)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Message))
  end

  @impl true
  def edit_message(%{channel_id: channel_id, id: message_id}, data) do
    edit_message(channel_id, message_id, data)
  end

  @impl true
  def edit_message(channel, message, data) do
    data = Map.new(data)

    :patch
    |> common_message(
      channel,
      message,
      &Endpoints.channel_messages/2,
      &Request.new(&1, &2, data)
    )
    |> Request.set_transform(Message)
  end

  @impl true
  def delete_message(%{channel_id: channel_id, id: message_id}) do
    delete_message(channel_id, message_id)
  end

  @impl true
  def delete_message(channel, message) do
    :delete
    |> common_message(
      channel,
      message,
      &Endpoints.channel_messages/2
    )
    # Separate route as this is an exception
    # See the first info box here:
    # https://discordapp.com/developers/docs/topics/rate-limits#rate-limits
    |> Map.update!(:route, &Kernel.<>(&1, "/delete"))
  end

  @impl true
  def delete_messages(channel, messages) do
    channel_id = Util.resolve_channel_id(channel)
    message_ids = Enum.map(messages, &Util.resolve_message_id/1)

    path = Endpoints.channel_messages_bulk_delete(channel_id)
    data = %{messages: message_ids}

    Request.new(:post, path, data)
  end

  @impl true
  def add_pinned_message(%{channel_id: channel_id, id: message_id}) do
    add_pinned_message(channel_id, message_id)
  end

  @impl true
  def add_pinned_message(channel, message) do
    common_message(
      :put,
      channel,
      message,
      &Endpoints.channel_pins/2
    )
  end

  @impl true
  def delete_pinned_message(%{channel_id: channel_id, id: message_id}) do
    delete_pinned_message(channel_id, message_id)
  end

  @impl true
  def delete_pinned_message(channel, message) do
    common_message(
      :delete,
      channel,
      message,
      &Endpoints.channel_pins/2
    )
  end

  @impl true
  def get_pinned_messages(channel) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_pins(channel_id)

    :get
    |> Request.new(path, channel_id)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Message))
  end

  ### End Message

  ### End Message

  ### Reaction

  @impl true
  def create_reaction(%{channel_id: channel_id, id: message_id}, emoji) do
    create_reaction(channel_id, message_id, emoji)
  end

  @impl true
  def create_reaction(channel, message, emoji) do
    common_message(
      :put,
      channel,
      message,
      &Endpoints.message_reactions(&1, &2, emoji, "@me")
    )
  end

  @impl true
  def get_reactions(
        channel_or_message,
        emoji_or_message_id,
        emoji_or_maybe_data \\ [],
        maybe_data \\ []
      )

  def get_reactions(%{channel_id: channel_id, id: message_id}, emoji, data, _) do
    get_reactions(channel_id, message_id, emoji, data)
  end

  def get_reactions(channel, message, emoji, data) do
    data = Keyword.new(data)

    :get
    |> common_message(
      channel,
      message,
      &Endpoints.message_reactions(&1, &2, emoji)
    )
    |> Request.set_params(data)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, User))
  end

  @impl true
  def delete_reaction(
        message_or_channel,
        emoji_or_message_id,
        emoji_or_maybe_user \\ "@me",
        mayber_user \\ "@me"
      )

  def delete_reaction(%{channel_id: channel_id, id: message_id}, emoji, user, _) do
    delete_reaction(channel_id, message_id, emoji, user)
  end

  def delete_reaction(channel, message, emoji, user) do
    user = Util.resolve_user_id(user)

    emoji = Emoji.to_identifier(emoji)

    common_message(
      :delete,
      channel,
      message,
      &Endpoints.message_reactions(&1, &2, emoji, user)
    )
  end

  @impl true
  def delete_all_reactions(%{channel_id: channel_id, id: message_id}, emoji) do
    delete_all_reactions(channel_id, message_id, emoji)
  end

  @impl true
  def delete_all_reactions(channel, message, emoji) do
    emoji = Emoji.to_identifier(emoji)

    common_message(
      :delete,
      channel,
      message,
      &Endpoints.message_reactions(&1, &2, emoji)
    )
  end

  ### End Reaction

  ### Channel

  @impl true
  def trigger_typing(channel) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_typing(channel_id)

    Request.new(:post, path)
  end

  @impl true
  def get_channel(channel) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel(channel_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(Channel)
  end

  @impl true
  def modify_channel(channel, data) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel(channel_id)

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:icon)

    :path
    |> Request.new(path, data)
    |> Request.set_transform(Channel)
  end

  @impl true
  def delete_channel(channel, reason \\ nil) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel(channel_id)

    :delete
    |> Request.new(path)
    |> Request.set_transform(Channel)
    |> Request.set_reason(reason)
  end

  @impl true
  def edit_channel_permissions(channel, target, data) when is_map(target) do
    channel_id = Util.resolve_channel_id(channel)

    {type, target_id} = Util.resolve_overwrite_target(target)

    data =
      data
      |> Map.new()
      |> Map.put_new(:type, type)

    edit_channel_permissions(channel_id, target_id, data)
  end

  def edit_channel_permissions(channel, target_id, data) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_permissions(channel_id, target_id)
    data = Map.new(data)

    Request.new(:put, path, data)
  end

  @impl true
  def delete_channel_permissions(channel, target, reason \\ nil) do
    channel_id = Util.resolve_channel_id(channel)
    {_type, target_id} = Util.resolve_overwrite_target(target)

    path = Endpoints.channel_permissions(channel_id, target_id)

    :delete
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  @impl true
  def get_channel_invites(channel) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_invites(channel_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(Invite)
  end

  @impl true
  def create_channel_invite(channel, data) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_invites(channel_id)
    data = Map.new(data)

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Invite)
  end

  ### End Channel

  ### Emojis

  @impl true
  def list_guild_emojis(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_emojis(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Emoji))
  end

  @impl true
  def get_guild_emoji(guild, emoji) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    path = Endpoints.guild_emojis(guild_id, emoji_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(Emoji)
  end

  @impl true
  def create_guild_emoji(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_emojis(guild_id)

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:image)
      |> case do
        %{:roles => [_ | _] = roles} = data ->
          roles = Enum.map(roles, &Util.resolve_role_id/1)
          Map.put(data, :roles, roles)
      end

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Emoji)
  end

  @impl true
  def modify_guild_emoji(guild, emoji, data) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    path = Endpoints.guild_emojis(guild_id, emoji_id)

    data
    |> Map.new()
    |> case do
      %{roles: roles} ->
        Map.put(data, :roles, Enum.map(roles, &Util.resolve_role_id/1))

      _ ->
        data
    end

    :patch
    |> Request.new(path, data)
    |> Request.set_transform(Emoji)
  end

  @impl true
  def delete_guild_emoji(guild, emoji, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    emoji_id = Util.resolve_emoji_id(emoji)

    path = Endpoints.guild_emojis(guild_id, emoji_id)

    :delete
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  ### End Emoji

  ### Guild

  @impl true
  def create_guild(data) do
    path = Endpoints.guild()

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:icon)

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Guild)
  end

  @impl true
  def get_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(Guild)
  end

  @impl true
  def modify_guild(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild(guild_id)

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:icon)
      |> Util.resolve_image_in_map(:splash)
      |> Util.resolve_image_in_map(:banner)

    :patch
    |> Request.new(path, data)
    |> Request.set_transform(Guild)
  end

  @impl true
  def delete_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild(guild_id)

    Request.new(:delete, path)
  end

  ### End Guild

  ### Guild Channel

  @impl true
  def get_guild_channels(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_channels(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Channel))
  end

  @impl true
  def create_guild_channel(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_channels(guild_id)
    data = Map.new(data)

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Channel)
  end

  @impl true
  def modify_guild_channel_positions(guild, channels) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_channels(guild_id)
    data = Enum.map(channels, &Util.resolve_channel_position/1)

    Request.new(:patch, path, data)
  end

  ### End Guild Channel

  ### Guild Member

  @impl true
  def get_guild_member(guild, user) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    path = Endpoints.guild_members(guild_id, user_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(Member)
  end

  @impl true
  def list_guild_members(guild, options) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_members(guild_id)
    data = Map.new(options)

    :get
    |> Request.new(path, data)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Member, :user))
  end

  @impl true
  def add_guild_member(guild, user, data) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    path = Endpoints.guild_members(guild_id, user_id)
    data = Map.new(data)

    :put
    |> Request.new(path, data)
    |> Request.set_transform(Member)
  end

  @impl true
  def modify_guild_member(guild, member, data) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)

    path = Endpoints.guild_members(guild_id, user_id)
    data = Map.new(data)

    Request.new(:patch, path, data)
  end

  @impl true
  def modify_current_users_nick(guild, nick, reason) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_own_nick(guild_id)

    data = %{nick: nick}

    :patch
    |> Request.new(path, data)
    |> Request.set_reason(reason)
  end

  ### End Guild Member

  ### Guild Ban

  @impl true
  def get_guild_bans(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_bans(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(
      &Map.new(&1, fn %{user: user} = entry ->
        user = Structs.create(user, User)
        {user.id, %{entry | user: user}}
      end)
    )
  end

  @impl true
  def get_guild_ban(guild, user) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    path = Endpoints.guild_bans(guild_id, user_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Map.update!(&1, :user, fn user -> Structs.create(user, User) end))
  end

  @impl true
  def create_guild_ban(guild, user, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    path = Endpoints.guild_bans(guild_id, user_id)

    :put
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  @impl true
  def remove_guild_ban(guild, user, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(user)

    path = Endpoints.guild_bans(guild_id, user_id)

    :delete
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  ### End Guild Ban

  ### Guild Roles

  @impl true
  def get_guild_roles(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_roles(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Role))
  end

  @impl true
  def create_guild_role(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_roles(guild_id)
    data = Map.new(data)

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Role)
  end

  @impl true
  def add_guild_member_role(guild, member, role, reason) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)
    role_id = Util.resolve_role_id(role)

    path = Endpoints.guild_member_roles(guild_id, user_id, role_id)

    :put
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  @impl true
  def remove_guild_member_role(guild, member, role, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    user_id = Util.resolve_user_id(member)
    role_id = Util.resolve_role_id(role)

    path = Endpoints.guild_member_roles(guild_id, user_id, role_id)

    :delete
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  @impl true
  def modify_guild_role_positions(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_roles(guild_id)
    data = Enum.map(data, &Util.resolve_guild_role_position/1)

    Request.new(:patch, path, data)
  end

  @impl true
  def modify_guild_role(guild, role, data) do
    guild_id = Util.resolve_guild_id(guild)
    role_id = Util.resolve_role_id(role)

    path = Endpoints.guild_roles(guild_id, role_id)
    data = Map.new(data)

    :patch
    |> Request.new(path, data)
    |> Request.set_transform(Role)
  end

  @impl true
  def delete_guild_role(guild, role, reason \\ nil) do
    guild_id = Util.resolve_guild_id(guild)
    role_id = Util.resolve_role_id(role)

    path = Endpoints.guild_roles(guild_id, role_id)

    :data
    |> Request.new(path)
    |> Request.set_reason(reason)
  end

  ### End Guild Roles

  ### Guild Prune

  @impl true
  def get_guild_prune_count(guild, days) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_prune(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_params(days: days)
    |> Request.set_transform(&Map.get(&1, :pruned))
  end

  @impl true
  def begin_guild_prune(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_prune(guild_id)
    data = Keyword.new(data)

    :post
    |> Request.new(path)
    |> Request.set_params(data)
    |> Request.set_transform(&Map.get(&1, :pruned))
  end

  ### End Guild Prune

  ### Guild Integration

  @impl true
  def get_guild_integrations(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_integrations(guild_id)

    Request.new(:get, path)
  end

  @impl true
  def create_guild_integration(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_integrations(guild_id)
    data = Map.new(data)

    Request.new(:post, path, data)
  end

  @impl true
  def modify_guild_integration(guild, integration, data) do
    guild_id = Util.resolve_guild_id(guild)
    integration_id = integration

    path = Endpoints.guild_integrations(guild_id, integration_id)
    data = Map.new(data)

    Request.new(:patch, path, data)
  end

  @impl true
  def delete_guild_integration(guild, integration) do
    guild_id = Util.resolve_guild_id(guild)
    integration_id = integration

    path = Endpoints.guild_integrations(guild_id, integration_id)

    Request.new(:delete, path)
  end

  @impl true
  def sync_guild_integration(guild, integration) do
    guild_id = Util.resolve_guild_id(guild)
    integration_id = integration

    path = Endpoints.guild_integrations(guild_id, integration_id)

    Request.new(:post, path)
  end

  ### End Guild Integration

  ### Guild Embed

  @impl true
  def get_guild_embed(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_embed(guild_id)

    Request.new(:get, path)
  end

  @impl true
  def modify_guild_embed(guild, data) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_embed(guild_id)
    data = Map.new(data)

    Request.new(:patch, path, data)
  end

  ### End Guild Embed

  ### Guild Invite

  @impl true
  def get_guild_invites(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_invites(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Invite, :code))
  end

  @impl true
  def get_guild_vanity_url(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_invites(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Map.get(&1, :code))
  end

  ### End Guild Invite

  ### Webhook

  @impl true
  def list_guild_webhooks(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_webhooks(guild_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Webhook))
  end

  @impl true
  def list_channel_webhooks(channel) do
    channel_id = Util.resolve_channel_id(channel)

    path = Endpoints.channel_webhooks(channel_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Webhook))
  end

  @impl true
  def get_webhook(user, token \\ nil) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook(user_id, token)

    :get
    |> Request.new(path)
    |> Request.set_transform(Webhook)
  end

  @impl true
  def update_webhook(user, token \\ nil, data) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook(user_id, token)

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:avatar)

    :patch
    |> Request.new(path, data)
    |> Request.set_transform(Webhook)
  end

  @impl true
  def delete_webhook(user, token \\ nil) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook(user_id, token)

    Request.new(:delete, path)
  end

  @impl true
  def execute_webhook(%{id: id, token: token}, data) do
    execute_webhook(id, token, false, data)
  end

  @impl true
  def execute_webhook(user, token, wait \\ false, data)

  @impl true
  def execute_webhook(%{id: id, token: token}, wait, _, data) do
    execute_webhook(id, token, wait, data)
  end

  @impl true
  def execute_webhook(user, token, wait, data) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook(user_id, token)

    {data, disposition} =
      data
      |> Map.new()
      |> Util.resolve_multipart()

    :post
    |> Request.new(path, data)
    |> Request.set_headers(disposition)
    |> Request.set_params(wait: wait)
    |> Request.set_transform(Message)
  end

  @impl true
  def execute_slack_webhook(%{id: id, token: token}, data) do
    execute_slack_webhook(id, token, false, data)
  end

  @impl true
  def execute_slack_webhook(user, token, wait \\ false, data)

  @impl true
  def execute_slack_webhook(%{id: id, token: token}, wait, _, data) do
    execute_slack_webhook(id, token, wait, data)
  end

  @impl true
  def execute_slack_webhook(user, token, wait, data) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook_slack(user_id, token)
    data = Map.new(data)

    :post
    |> Request.new(path, data)
    |> Request.set_params(wait: wait)
    |> Request.set_transform(Message)
  end

  @impl true
  def execute_github_webhook(%{id: id, token: token}, event, data) do
    execute_github_webhook(id, token, event, false, data)
  end

  @impl true
  def execute_github_webhook(user, token, event, wait \\ false, data)

  @impl true
  def execute_github_webhook(%{id: id, token: token}, event, wait, _, data) do
    execute_github_webhook(id, token, event, wait, data)
  end

  @impl true
  def execute_github_webhook(user, token, event, wait, data) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.webhook_github(user_id, token)
    data = Map.new(data)

    :post
    |> Request.new(
      path,
      data
    )
    |> Request.set_headers([{"x-github-event", event}])
    |> Request.set_params(wait: wait)
    |> Request.set_transform(Message)
  end

  ### End Webhook

  ### Guild Misc

  @impl true
  def get_audit_logs(guild, data \\ []) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_audit_logs(guild_id)
    data = Map.new(data)

    :get
    |> Request.new(path)
    |> Request.set_params(data)
    |> Request.set_transform(AuditLog)
  end

  @impl true
  def get_guild_voice_regions(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.guild_regions(guild_id)

    Request.new(:get, path)
  end

  @impl true
  def get_invite(code) do
    path = Endpoints.invite(code)

    :get
    |> Request.new(path)
    |> Request.set_transform(Invite)
  end

  def delete_invite(%{code: code}), do: delete_invite(code)

  @impl true
  def delete_invite(code) do
    path = Endpoints.invite(code)

    :delete
    |> Request.new(path)
    |> Request.set_transform(Invite)
  end

  @impl true
  def get_user(user) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.users(user_id)

    :get
    |> Request.new(path)
    |> Request.set_transform(User)
  end

  @impl true
  def get_current_user() do
    path = Endpoints.me()

    :get
    |> Request.new(path)
    |> Request.set_transform(User)
  end

  @impl true
  def modify_current_user(data) do
    path = Endpoints.me()

    data =
      data
      |> Map.new()
      |> Util.resolve_image_in_map(:avatar)

    :post
    |> Request.new(path, data)
    |> Request.set_transform(User)
  end

  @impl true
  def get_current_user_guilds(data) do
    path = Endpoints.me_guilds()
    data = Map.new(data)

    :get
    |> Request.new(path, data)
    |> Request.set_transform(&Structs.Util.raw_data_to_map(&1, Guild))
  end

  @impl true
  def leave_guild(guild) do
    guild_id = Util.resolve_guild_id(guild)

    path = Endpoints.me_guilds(guild_id)

    Request.new(:delete, path)
  end

  @impl true
  def create_dm(user) do
    user_id = Util.resolve_user_id(user)

    path = Endpoints.me_channels()
    data = %{recipient_id: user_id}

    :post
    |> Request.new(path, data)
    |> Request.set_transform(Channel)
  end

  @impl true
  def gateway() do
    path = Endpoints.gateway()

    Request.new(:get, path)
  end

  @impl true
  def gateway_bot() do
    path = Endpoints.gateway_bot()

    Request.new(:get, path)
  end

  ### End Guild Misc

  ### Helpers

  # helper function to reduce redundant resolving
  defp common_message(verb, channel, message, path_fun, request_fun \\ &Request.new/2) do
    channel_id = Util.resolve_channel_id(channel)
    message_id = Util.resolve_message_id(message)

    path = path_fun.(channel_id, message_id)
    request_fun.(verb, path)
  end

  ### End Helpers
end
