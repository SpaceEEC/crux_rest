defmodule Crux.Rest.CDN do
  @moduledoc """
  Functions to generate CDN urls pointing to avatars, icons, etc.

  Relevant upstream documentation: [Discord Developer Documentation](https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints)
  """
  @moduledoc since: "0.1.5"

  @typedoc """
  Specifies the file type / extension and size of the resource url to generate.

  Notes:
  * `:size` has to be any power of two between 16 and 4096
  * `:extension` has to be one of "jpg", "jpeg", "png", "webp", "gif"
  * `:animated` whether to keep "gif" if the resource is animated regardless of `:extension`
  * See the docs of each function for information what sizes / extensions are valid there.
  """
  @typedoc since: "0.1.5"

  @type format_options ::
          %{
            optional(:size) => pos_integer(),
            optional(:extension) => String.t(),
            optional(:animated) => boolean()
          }
          | [{:size, pos_integer()} | {:extension, String.t()} | {:animated, boolean()}]

  @base_url "https://cdn.discordapp.com"

  @doc """
  Base CDN address.
  """
  @spec base_url() :: String.t()
  @doc since: "0.1.5"
  def base_url(), do: @base_url

  @doc """
  Generates the url to an emoji.

  This function does not accept any `t:format_options/0`.

  ```elixir
  # A struct
  iex> %Crux.Structs.Emoji{id: 438226248293154816, animated: false}
  ...> |> Crux.Rest.CDN.custom_emoji()
  "#{@base_url}/emojis/438226248293154816.png"

  # A plain map
  iex> %{id: 438226248293154816, animated: true}
  ...> |> Crux.Rest.CDN.custom_emoji()
  "#{@base_url}/emojis/438226248293154816.gif"

  ```
  """
  @spec custom_emoji(
          Crux.Structs.Emoji.t()
          | %{id: Crux.Structs.Snowflake.t(), animated: boolean()}
        ) :: String.t()
  @doc since: "0.1.5"
  def custom_emoji(emoji)

  def custom_emoji(%{id: id, animated: animated}) do
    "#{@base_url}/emojis/#{id}.#{if animated, do: "gif", else: "png"}"
  end

  @doc """
  Generates the url to group dm channel's icon.

  If the group dm channel has no icon, nil will be returned.

  ```elixir
  # A struct
  iex> %Crux.Structs.Channel{id: 354042501201526786, icon: "ecd7839b9eed535f1ae3a545c5d5f3c8"}
  ...> |> Crux.Rest.CDN.group_dm_icon()
  "#{@base_url}/channel-icons/354042501201526786/ecd7839b9eed535f1ae3a545c5d5f3c8.webp"

  # A plain map
  iex> %{id: 354042501201526786, icon: "ecd7839b9eed535f1ae3a545c5d5f3c8"}
  ...> |> Crux.Rest.CDN.group_dm_icon()
  "#{@base_url}/channel-icons/354042501201526786/ecd7839b9eed535f1ae3a545c5d5f3c8.webp"

    # With format options
  iex> %Crux.Structs.Channel{id: 354042501201526786, icon: "ecd7839b9eed535f1ae3a545c5d5f3c8"}
  ...> |> Crux.Rest.CDN.group_dm_icon(size: 16, extension: "png")
  "#{@base_url}/channel-icons/354042501201526786/ecd7839b9eed535f1ae3a545c5d5f3c8.png?size=16"

  # Without icon
  iex> %{icon: nil}
  ...> |> Crux.Rest.CDN.group_dm_icon()
  nil

  ```
  """
  @spec group_dm_icon(
          Crux.Structs.Channel.t()
          | %{id: Crux.Structs.Snowflake.t(), icon: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @doc since: "0.1.5"
  def group_dm_icon(group_dm, options \\ [])
  def group_dm_icon(%{icon: nil}, _options), do: nil

  def group_dm_icon(%{id: id, icon: icon}, options) do
    extension = get_extension(icon, options[:animated], options[:extension])
    url = "#{@base_url}/channel-icons/#{id}/#{icon}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to a guild's icon.

  If the guild has no icon, nil will be returned.

  ```elixir
  # A guild struct
  iex> %Crux.Structs.Guild{id: 269508806759809042, icon: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_icon()
  "#{@base_url}/icons/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

  # A plain map
  iex> %{id: 269508806759809042, icon: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_icon()
  "#{@base_url}/icons/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

  # With format_options
  iex> %Crux.Structs.Guild{id: 269508806759809042, icon: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_icon(size: 16, extension: "png")
  "#{@base_url}/icons/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.png?size=16"

  # Without icon
  iex> %Crux.Structs.Guild{id: 269508806759809042, icon: nil}
  ...> |> Crux.Rest.CDN.guild_icon()
  nil

  ```
  """
  @spec guild_icon(
          Crux.Structs.Guild.t() | %{id: Crux.Structs.Snowflake.t(), icon: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @doc since: "0.1.5"
  def guild_icon(guild, options \\ [])
  def guild_icon(%{icon: nil}, _options), do: nil

  def guild_icon(%{id: id, icon: icon}, options) do
    extension = get_extension(icon, options[:animated], options[:extension])
    url = "#{@base_url}/icons/#{id}/#{icon}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to a guild's splash.

  If the guild has no splash, nil will be returned.

  The extension "gif" is not valid here.

  ```elixir
  # A struct
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_splash()
  "#{@base_url}/splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

    # A plain map
  iex> %{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_splash()
  "#{@base_url}/splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

  # With format_options
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_splash(size: 16, extension: "png")
  "#{@base_url}/splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.png?size=16"

  # Without splash
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: nil}
  ...> |> Crux.Rest.CDN.guild_splash()
  nil

  ```
  """
  @spec guild_splash(
          Crux.Structs.Guild.t() | %{id: Crux.Structs.Snowflake.t(), splash: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @doc since: "0.1.5"
  def guild_splash(guild, options \\ [])
  def guild_splash(%{splash: nil}, _options), do: nil

  def guild_splash(%{id: id, splash: splash}, options) do
    extension = get_extension(splash, options[:animated], options[:extension])
    url = "#{@base_url}/splashes/#{id}/#{splash}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to a guild's discovery splash.

  If the guild has no discovery splash, nil will be returned.

  The extension "gif" is not valid here.

  ```elixir
  # A struct
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_discovery_splash()
  "#{@base_url}/discovery-splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

    # A plain map
  iex> %{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_discovery_splash()
  "#{@base_url}/discovery-splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.webp"

  # With format_options
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: "15abb45cf1c59f90ea291185b99ab1dd"}
  ...> |> Crux.Rest.CDN.guild_discovery_splash(size: 16, extension: "png")
  "#{@base_url}/discovery-splashes/269508806759809042/15abb45cf1c59f90ea291185b99ab1dd.png?size=16"

  # Without splash
  iex> %Crux.Structs.Guild{id: 269508806759809042, splash: nil}
  ...> |> Crux.Rest.CDN.guild_discovery_splash()
  nil

  ```
  """
  @spec guild_discovery_splash(
          Crux.Structs.Guild.t() | %{id: Crux.Structs.Snowflake.t(), splash: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @doc since: "0.3.0"
  def guild_discovery_splash(guild, options \\ [])
  def guild_discovery_splash(%{splash: nil}, _options), do: nil

  def guild_discovery_splash(%{id: id, splash: splash}, options) do
    extension = get_extension(splash, options[:animated], options[:extension])
    url = "#{@base_url}/discovery-splashes/#{id}/#{splash}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to a guild banner.

  If the guild has no banner, nil will be returned.

  The extension "gif" is not valid here.

  ```elixir
  # A struct
  iex> %Crux.Structs.Guild{id: 269508806759809042, banner: "29c1980a3471cb2d5c1208c5196278fb"}
  ...> |> Crux.Rest.CDN.guild_banner()
  "#{@base_url}/banners/269508806759809042/29c1980a3471cb2d5c1208c5196278fb.webp"

    # A plain map
  iex> %{id: 269508806759809042, banner: "29c1980a3471cb2d5c1208c5196278fb"}
  ...> |> Crux.Rest.CDN.guild_banner()
  "#{@base_url}/banners/269508806759809042/29c1980a3471cb2d5c1208c5196278fb.webp"

  # With format_options
  iex> %Crux.Structs.Guild{id: 269508806759809042, banner: "29c1980a3471cb2d5c1208c5196278fb"}
  ...> |> Crux.Rest.CDN.guild_banner(size: 16, extension: "png")
  "#{@base_url}/banners/269508806759809042/29c1980a3471cb2d5c1208c5196278fb.png?size=16"

  # Without banner
  iex> %Crux.Structs.Guild{id: 269508806759809042, banner: nil}
  ...> |> Crux.Rest.CDN.guild_banner()
  nil

  ```
  """
  @spec guild_banner(
          Crux.Structs.Guild.t() | %{id: Crux.Structs.Snowflake.t(), banner: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @doc since: "0.2.0"
  def guild_banner(guild, options \\ [])
  def guild_banner(%{banner: nil}, _options), do: nil

  def guild_banner(%{id: id, banner: banner}, options) do
    extension = get_extension(banner, options[:animated], options[:extension])
    url = "#{@base_url}/banners/#{id}/#{banner}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to the default avatar url of a user.

  ```elixir
  # A struct
  iex> %Crux.Structs.User{discriminator: "0001"}
  ...> |> Crux.Rest.CDN.default_user_avatar()
  "#{@base_url}/embed/avatars/1.png"

  # A plain map
  iex> %{discriminator: "0001"}
  ...> |> Crux.Rest.CDN.default_user_avatar()
  "#{@base_url}/embed/avatars/1.png"

  ```
  """
  @spec default_user_avatar(Crux.Structs.User.t() | %{discriminator: String.t()}) :: String.t()
  @doc since: "0.1.5"
  def default_user_avatar(user)

  def default_user_avatar(%{discriminator: discrim}) do
    user_discriminator = discrim |> String.to_integer() |> rem(5)
    "#{@base_url}/embed/avatars/#{user_discriminator}.png"
  end

  @doc """
  Generates a url to a user avatar.

  If the user has no custom avatar, this will return a default one with the extension "png".

  The extension defaults to "gif" or "webp" depending on whether the user has an animated avatar.

  ```elixir
  # A struct with an avatar
  iex> %Crux.Structs.User{id: 218348062828003328, avatar: "646a356e237350bf8b8dfde15667dfc4"}
  ...> |> Crux.Rest.CDN.user_avatar()
  "#{@base_url}/avatars/218348062828003328/646a356e237350bf8b8dfde15667dfc4.webp"

  # A plain map with an avatar
  iex> %{id: 218348062828003328, avatar: "646a356e237350bf8b8dfde15667dfc4"}
  ...> |> Crux.Rest.CDN.user_avatar()
  "#{@base_url}/avatars/218348062828003328/646a356e237350bf8b8dfde15667dfc4.webp"

  # With format options
  iex> %Crux.Structs.User{id: 218348062828003328, avatar: "646a356e237350bf8b8dfde15667dfc4"}
  ...> |> Crux.Rest.CDN.user_avatar(extension: "png", size: 2048)
  "#{@base_url}/avatars/218348062828003328/646a356e237350bf8b8dfde15667dfc4.png?size=2048"

  # A struct without an avatar
  iex> %Crux.Structs.User{id: 218348062828003328, avatar: nil, discriminator: "0001"}
  ...> |> Crux.Rest.CDN.user_avatar()
  "#{@base_url}/embed/avatars/1.png"

  ```
  """
  @spec user_avatar(
          Crux.Structs.User.t()
          | %{id: Crux.Structs.Snowflake.t(), discriminator: String.t(), avatar: String.t() | nil},
          format_options()
        ) :: String.t()
  @doc since: "0.1.5"
  def user_avatar(user, options \\ [])

  def user_avatar(%{avatar: nil} = user, _options), do: default_user_avatar(user)

  def user_avatar(%{id: id, avatar: avatar}, options) do
    extension = get_extension(avatar, options[:animated], options[:extension])
    url = "#{@base_url}/avatars/#{id}/#{avatar}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to an application icon.

  ```elixir
  # A map with an icon
  iex> %{id: 560524012627820547, icon: "cb861044ce722df3e5a9547a2a012a04"}
  ...> |> Crux.Rest.CDN.application_icon()
  "#{@base_url}/app-icons/560524012627820547/cb861044ce722df3e5a9547a2a012a04.webp"

  # With format options
  iex> %{id: 560524012627820547, icon: "cb861044ce722df3e5a9547a2a012a04"}
  ...> |> Crux.Rest.CDN.application_icon(extension: "png", size: 2048)
  "#{@base_url}/app-icons/560524012627820547/cb861044ce722df3e5a9547a2a012a04.png?size=2048"

  # A map without an icon
  iex> %{id: 560524012627820547, icon: nil}
  ...> |> Crux.Rest.CDN.application_icon()
  nil

  ```
  """
  @spec application_icon(
          application :: %{icon: String.t() | nil, id: Snowflake.t()},
          format_options
        ) :: String.t() | nil
  @doc since: "0.3.0"
  def application_icon(application, options \\ [])

  def application_icon(%{icon: nil}, _options), do: nil

  def application_icon(%{id: id, icon: icon}, options) do
    extension = get_extension(icon, options[:animated], options[:extension])
    url = "#{@base_url}/app-icons/#{id}/#{icon}.#{extension}"

    append_size(url, options[:size])
  end

  @doc """
  Generates a url to a team icon.

  ```elixir
  # A map with an icon
  iex> %{id: 701002408041512991, icon: "cb861044ce722df3e5a9547a2a012a04"}
  ...> |> Crux.Rest.CDN.team_icon()
  "#{@base_url}/team-icons/701002408041512991/cb861044ce722df3e5a9547a2a012a04.webp"

  # With format options
  iex> %{id: 701002408041512991, icon: "cb861044ce722df3e5a9547a2a012a04"}
  ...> |> Crux.Rest.CDN.team_icon(extension: "png", size: 2048)
  "#{@base_url}/team-icons/701002408041512991/cb861044ce722df3e5a9547a2a012a04.png?size=2048"

  # A map without an icon
  iex> %{id: 701002408041512991, icon: nil}
  ...> |> Crux.Rest.CDN.team_icon()
  nil

  ```
  """
  @spec team_icon(
          team :: %{icon: String.t() | nil, id: Snowflake.t()},
          format_options
        ) :: String.t() | nil
  @doc since: "0.3.0"
  def team_icon(team, options \\ [])

  def team_icon(%{icon: nil}, _options), do: nil

  def team_icon(%{id: id, icon: icon}, options) do
    extension = get_extension(icon, options[:animated], options[:extension])
    url = "#{@base_url}/team-icons/#{id}/#{icon}.#{extension}"

    append_size(url, options[:size])
  end

  @spec get_extension(
          hash :: String.t(),
          animated :: boolean(),
          extension :: String.t()
        ) :: String.t()
  defp get_extension("a_" <> _rest, animated, extension)
       # Keep gif extension if animated is true
       when animated == true
       # Default to gif if no other extension is given
       when is_nil(extension) do
    "gif"
  end

  # No extension provided, default to webp
  defp get_extension(_hash, _animated, nil), do: "webp"
  # An extension was provided, use it
  defp get_extension(_hash, falsy, extension)
       when falsy in [nil, false] do
    extension
  end

  defp append_size(str, nil), do: str
  defp append_size(str, size), do: "#{str}?size=#{size}"
end
