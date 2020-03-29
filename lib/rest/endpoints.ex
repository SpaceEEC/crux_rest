defmodule Crux.Rest.Endpoints do
  @moduledoc """
  Endpoints being used by the `Crux.Rest` module.
  You usually do not need to worry about this.
  """
  @moduledoc since: "0.1.0"

  use Crux.Rest.Endpoints.Generator

  @base_url "https://discordapp.com/api"

  @doc """
  Base API url, with or without a version.
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

    route("/permissions")

    route("/pins/:message_id")

    route("/typings")
    route("/webhooks")
  end

  route("/gateway/bot")

  route "/guilds/:guild_id" do
    route("/audit-logs")
    route("/bans")
    route("/channels")
    route("/embed")
    route("/emojis")
    route("/integrations")
    route("/invites")

    route "/members" do
      route("/@me/nick")

      route("/:member_id/roles/:role_id")
    end

    route("/preview")
    route("/prune")
    route("/regions")
    route("/roles")
    route("/webhooks")
  end

  route("/invites/:code")

  route "/users" do
    route "/@me" do
      route("/channels")
      route("/guilds/:guild_id")
    end

    route("/:user_id")
  end

  route "/webhooks/:webhook_id/:token" do
    route("/github")
    route("/slack")
  end

  route("/oauth2/applictions/@me")
end
