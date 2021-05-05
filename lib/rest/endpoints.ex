defmodule Crux.Rest.Endpoints do
  @moduledoc """
  Endpoints being used by the `Crux.Rest` module.
  All functions except `base_url/1` are automatically generated depending on the routes Discord documents.

  You usually do not need to worry about this module.
  """
  @moduledoc since: "0.1.0"

  use Crux.Rest.Endpoints.Generator

  @base_url "https://discord.com/api"

  @doc """
  Base API url, with or without a version.

  ```elixir
  iex> Crux.Rest.Endpoints.base_url(nil)
  "#{@base_url}"

  iex> Crux.Rest.Endpoints.base_url(8)
  "#{@base_url}/v8"
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
    route("/followers")

    route("/invites")

    route "/messages" do
      route("/bulk-delete")

      route "/:message_id" do
        route("/crosspost")

        route "/reactions/:emoji" do
          route("/:user_id")
          route("/@me")
        end
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
    route("/emojis/:emoji_id")
    route("/integrations/:integration_id/sync")
    route("/invites")

    route "/members" do
      route("/@me/nick")

      route("/:member_id/roles/:role_id")

      route("/search")
    end

    route("/preview")
    route("/prune")
    route("/regions")
    route("/roles/:role_id")
    route("/templates/:template_code")
    route("/vanity-url")
    route("/webhooks")
    route("/widget")
    route("/widget.json")
    route("/welcome-screen")
  end

  route("/invites/:code")

  route "/oauth2" do
    route("/applications/@me")
    route("/@me")
  end

  route "/users" do
    route "/@me" do
      route("/channels")
      route("/guilds/:guild_id")
    end

    route("/:user_id")
  end

  route("/voice/regions")

  route "/webhooks/:webhook_or_application_id/:token_or_interaction_token" do
    route "/messages" do
      route("/:message_id")
      route("/@original")
    end

    route("/github")
    route("/slack")
  end

  route "/applications/:application_id" do
    route("/commands/:command_id")
    route("/guilds/:guild_id/commands/:command_id")
  end

  route("/interactions/:interaction_id/:interaction_token/callback")
end
