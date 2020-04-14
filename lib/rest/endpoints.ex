defmodule Crux.Rest.Endpoints do
  @moduledoc """
  Endpoints being used by the `Crux.Rest` module.
  All functions except `base_url/1` are automatically generated depending on the routes Discord documents.

  You usually do not need to worry about this module.
  """
  @moduledoc since: "0.1.0"

  use Crux.Rest.Endpoints.Generator

  @base_url "https://discordapp.com/api"

  @doc """
  Base API url, with or without a version.

  ```elixir
  iex> Crux.Rest.Endpoints.base_url(nil)
  "#{@base_url}"

  iex> Crux.Rest.Endpoints.base_url(7)
  "#{@base_url}/v7"
  ```
  """
  @spec base_url(version :: integer() | nil) :: String.t()
  @doc since: "0.3.0"
  def base_url(version)

  def base_url(nil), do: @base_url

  def base_url(version) when is_integer(version) do
    "#{base_url(nil)}/v#{version}"
  end

  route "/channels/:channel_id" do
    route("/invites")

    route "/messages" do
      route("/bulk-delete")

      route "/:message_id/reactions/:emoji" do
        route("/:user_id")
        route("/@me")
      end
    end

    route("/permissions/:overwrite_id")

    route("/pins/:message_id")

    route("/typing")
    route("/webhooks")
  end

  route("/gateway/bot")

  route "/guilds/:guild_id" do
    route("/audit-logs")
    route("/bans/:member_id")
    route("/channels")
    route("/embed")
    route("/emojis/:emoji_id")
    route("/integrations/:integration_id/sync")
    route("/invites")

    route "/members" do
      route("/@me/nick")

      route("/:member_id/roles/:role_id")
    end

    route("/preview")
    route("/prune")
    route("/regions")
    route("/roles/:role_id")
    route("/vanity-url")
    route("/webhooks")
  end

  route("/invites/:code")

  route("/oauth2/applictions/@me")

  route "/users" do
    route "/@me" do
      route("/channels")
      route("/guilds/:guild_id")
    end

    route("/:user_id")
  end

  route("/voice/regions")

  route "/webhooks/:webhook_id/:token" do
    route("/github")
    route("/slack")
  end
end
