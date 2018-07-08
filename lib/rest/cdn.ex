defmodule Crux.Rest.CDN do
  @moduledoc """
    Functions to generate cdn urls pointing to avatars, icons, etc.
  """

  @typedoc """
    Specifies the file type / extension and size of the resource url to generate.

    Notes:
  * `:size` has to be any power of two between 16 and 2048
  * `:extension` has to be one of "jpg", "jpeg", "png", "webp", "gif"
  * See the docs of each function for information what sizes / extensions are valid there.
  """
  @type format_options :: %{
          optional(:size) => pos_integer(),
          optional(:extension) => String.t()
        }

  @base_url "https://cdn.discordapp.com"

  @doc """
    Base CDN address.
  """
  @spec base_url() :: String.t()
  @since "0.1.5"
  def base_url, do: @base_url

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
  @spec custom_emoji(Crux.Structs.Emoji.t() | %{id: Crux.Rest.snowflake()}) :: String.t()
  @since "0.1.5"
  def custom_emoji(emoji)

  def custom_emoji(%{id: id, animated: animated}),
    do: "#{@base_url}/emojis/#{id}.#{if animated, do: "gif", else: "png"}"

  @doc """
    Generates a url to group dm channel icon.

    If the group dm channel has no icon nil will be returned.

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
          | %{id: Crux.Rest.snowflake(), icon: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @since "0.1.5"
  def group_dm_icon(group_dm, options \\ [])
  def group_dm_icon(%{icon: nil}, _options), do: nil

  def group_dm_icon(%{id: id, icon: icon}, options) do
    extension = options[:extension] || "webp"
    qs = if options[:size], do: "?size=#{options[:size]}", else: ""
    "#{@base_url}/channel-icons/#{id}/#{icon}.#{extension}#{qs}"
  end

  @doc """
    Generates a url to a guild icon.

    If the guild has no icon nil will be returned.

    The extension "gif" is not valid here.

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
          Crux.Structs.Guild.t() | %{id: Crux.Rest.snowflake(), icon: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @since "0.1.5"
  def guild_icon(guild, options \\ [])
  def guild_icon(%{icon: nil}, _options), do: nil

  def guild_icon(%{id: id, icon: icon}, options) do
    extension = options[:extension] || "webp"
    qs = if options[:size], do: "?size=#{options[:size]}", else: ""
    "#{@base_url}/icons/#{id}/#{icon}.#{extension}#{qs}"
  end

  @doc """
    Generates a url to a guild splash.

    The extension "gif" is valid here.

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
          Crux.Structs.Guild.t() | %{id: Crux.Rest.snowflake(), splash: String.t() | nil},
          format_options()
        ) :: String.t() | nil
  @since "0.1.5"
  def guild_splash(guild, options \\ [])
  def guild_splash(%{splash: nil}, _options), do: nil

  def guild_splash(%{id: id, splash: splash}, options) do
    extension = options[:extension] || "webp"
    qs = if options[:size], do: "?size=#{options[:size]}", else: ""
    "#{@base_url}/splashes/#{id}/#{splash}.#{extension}#{qs}"
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
  @since "0.1.5"
  def default_user_avatar(user)

  def default_user_avatar(%{discriminator: discrim}) do
    user_discriminator = String.to_integer(discrim) |> rem(5)
    "#{@base_url}/embed/avatars/#{user_discriminator}.png"
  end

  @doc """
    Generates a url to a user.

    If the user has no custom avatar this will return a default one with the extension "webp".

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
          | %{id: Crux.Rest.snowflake(), discriminator: String.t(), avatar: String.t() | nil},
          format_options()
        ) :: String.t()
  @since "0.1.5"
  def user_avatar(user, options \\ [])

  def user_avatar(%{avatar: nil} = user, _options), do: default_user_avatar(user)

  def user_avatar(%{id: id, avatar: avatar}, options) do
    extension =
      cond do
        options[:extension] ->
          options[:extension]

        match?("a_" <> _rest, avatar) ->
          "gif"

        true ->
          "webp"
      end

    qs = if options[:size], do: "?size=#{options[:size]}", else: ""

    "#{@base_url}/avatars/#{id}/#{avatar}.#{extension}#{qs}"
  end
end
