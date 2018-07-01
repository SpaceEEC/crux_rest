defmodule Crux.Rest.Endpoints do
  @moduledoc """
    Endpoints being used by the `Crux.Rest` module, you do not need to worry about it.
  """

  @doc """
    Base API address.
  """
  @spec api() :: String.t()
  def api, do: "https://discordapp.com/api/v7"

  @doc """
    Base CDN address.

    Deprecated, use `Crux.Rest.CDN.cdn/0` instead.
  """
  @deprecated "Use Crux.Structs.CDN.cdn/0 instead"
  @spec cdn() :: String.t()
  def cdn, do: "https://cdn.discordapp.com"

  @doc """
    Used to obtain the gateway address.
  """
  @spec gateway() :: String.t()
  def gateway, do: "/gateway"

  @doc """
    Used to obtain the gateway address along the recommended shard count.
  """
  @spec gateway_bot() :: String.t()
  def gateway_bot, do: "#{gateway()}/bot"

  @doc """
    Used for invite related functions.
  """
  @spec invite(code :: String.t() | nil) :: String.t()
  def invite(code \\ nil)
  def invite(nil), do: "/invites"
  def invite(code), do: "#{invite()}/#{code}"

  @doc """
    Used for channel related functions.
  """
  @spec channel(channel_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def channel(channel_id, suffix \\ nil)
  def channel(channel_id, nil), do: "/channels/#{channel_id}"
  def channel(channel_id, suffix), do: "#{channel(channel_id)}/#{suffix}"

  @doc """
    Used for channel messages related functions.
  """
  @spec channel_messages(channel_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) ::
          String.t()
  def channel_messages(channel_id, suffix \\ nil)
  def channel_messages(channel_id, nil), do: channel(channel_id, "messages")
  def channel_messages(channel_id, suffix), do: "#{channel_messages(channel_id)}/#{suffix}"

  @doc """
    Used for reactions related functions.
  """
  @spec message_reactions(
          channel_id :: Crux.Rest.snowflake(),
          message_id :: Crux.Rest.snowflake(),
          emoji :: String.t(),
          suffix :: String.t() | nil
        ) :: String.t()
  def message_reactions(channel_id, message_id, emoji, suffix \\ nil)

  def message_reactions(channel_id, message_id, emoji, nil),
    do: "#{channel_messages(channel_id, message_id)}/reactions/#{emoji}"

  def message_reactions(channel_id, message_id, emoji, suffix),
    do: "#{message_reactions(channel_id, message_id, emoji)}/#{suffix}"

  @doc """
    Used for pin related functions.
  """
  @spec channel_pins(
          channel_id :: Crux.Rest.snowflake(),
          suffix :: String.t() | nil
        ) :: String.t()
  def channel_pins(channel_id, suffix \\ nil)
  def channel_pins(channel_id, nil), do: channel(channel_id, "pins")
  def channel_pins(channel_id, suffix), do: "#{channel_pins(channel_id)}/#{suffix}"

  @doc """
    Used for channel permissions related functions.
  """
  @spec channel_permissions(
          channel_id :: Crux.Rest.snowflake(),
          target_id :: Crux.Rest.snowflake()
        ) :: String.t()
  def channel_permissions(channel_id, target_id),
    do: "#{channel(channel_id, "permissions")}/#{target_id}"

  @doc """
    Used for guild related functions.
  """
  @spec guild(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def guild(guild_id \\ nil, suffix \\ nil)
  def guild(nil, nil), do: "/guilds"
  def guild(guild_id, nil), do: "/guilds/#{guild_id}"
  def guild(guild_id, suffix), do: "#{guild(guild_id)}/#{suffix}"

  @doc """
    Used for guild emoji related functions.
  """
  @spec guild_emojis(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def guild_emojis(guild_id, suffix \\ nil)
  def guild_emojis(guild_id, nil), do: "#{guild(guild_id)}/emojis"
  def guild_emojis(guild_id, suffix), do: "#{guild_emojis(guild_id)}/#{suffix}"

  @doc """
    Used for guild members related functions.
  """
  @spec guild_members(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def guild_members(guild_id, suffix \\ nil)
  def guild_members(guild_id, nil), do: "#{guild(guild_id)}/members"
  def guild_members(guild_id, suffix), do: "#{guild_members(guild_id)}/#{suffix}"

  @doc """
    Used for ban related functions.
  """
  @spec guild_bans(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def guild_bans(guild_id, suffix \\ nil)
  def guild_bans(guild_id, nil), do: "#{guild(guild_id)}/bans"
  def guild_bans(guild_id, suffix), do: "#{guild_bans(guild_id)}/#{suffix}"

  @doc """
    Used for role related functions.
  """
  @spec guild_roles(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) :: String.t()
  def guild_roles(guild_id, suffix \\ nil)
  def guild_roles(guild_id, nil), do: "#{guild(guild_id)}/roles"
  def guild_roles(guild_id, suffix), do: "#{guild_roles(guild_id)}/#{suffix}"

  @doc """
    Used for integration related functions.
  """
  @spec guild_integrations(guild_id :: Crux.Rest.snowflake(), suffix :: String.t() | nil) ::
          String.t()
  def guild_integrations(guild_id, suffix \\ nil)
  def guild_integrations(guild_id, nil), do: "#{guild(guild_id)}/integrations"
  def guild_integrations(guild_id, suffix), do: "#{guild_integrations(guild_id)}/#{suffix}"

  @doc """
    Used for role related functions.
  """
  @spec guild_member_roles(
          guild_id :: Crux.Rest.snowflake(),
          member_id :: Crux.Rest.snowflake(),
          role_id :: Crux.Rest.snowflake()
        ) :: String.t()

  def guild_member_roles(guild_id, member_id, role_id \\ nil)

  def guild_member_roles(guild_id, member_id, nil),
    do: "#{guild_members(guild_id, member_id)}/roles"

  def guild_member_roles(guild_id, member_id, role_id),
    do: "#{guild_members(guild_id, member_id)}/roles/#{role_id}"

  @doc """
  Discord being special.
  """
  # I don't even
  @spec guild_own_nick(guild_id :: Crux.Rest.snowflake()) :: String.t()
  def guild_own_nick(guild_id), do: "#{guild_members(guild_id, "@me")}/nick"

  @doc """
    Used for functions related to users.
  """
  @spec users(suffix :: String.t()) :: String.t()
  def users(suffix \\ nil)
  def users(nil), do: "/users/"
  def users(suffix), do: "#{users()}/#{suffix}"

  @doc """
    Used for functions related to the current user.
  """
  @spec me(suffix :: String.t()) :: String.t()
  def me(suffix \\ nil)
  def me(nil), do: "/users/@me"
  def me(suffix), do: "#{me()}/#{suffix}"

  @doc """
    Used for functions related to the current user's guilds.
  """
  @spec me_guilds(suffix :: String.t()) :: String.t()
  def me_guilds(suffix \\ nil)
  def me_guilds(nil), do: "#{me()}/guilds"
  def me_guilds(suffix), do: "#{me_guilds()}/#{suffix}"
end
