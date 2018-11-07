defmodule Crux.Rest.MixProject do
  use Mix.Project

  @vsn "0.1.7"
  @name :crux_rest

  def project do
    [
      start_permanent: Mix.env() == :prod,
      package: package(),
      app: @name,
      version: @vsn,
      elixir: "~> 1.6",
      description: "Package providing rest functions and rate limiting for the Discord API",
      source_url: "https://github.com/SpaceEEC/#{@name}/",
      homepage_url: "https://github.com/SpaceEEC/#{@name}/",
      deps: deps()
    ]
  end

  def package do
    [
      name: @name,
      licenses: ["MIT"],
      maintainers: ["SpaceEEC"],
      links: %{
        "GitHub" => "https://github.com/SpaceEEC/#{@name}/",
        "Changelog" => "https://github.com/SpaceEEC/#{@name}/releases/tag/#{@vsn}",
        "Documentation" => "https://hexdocs.pm/#{@name}/#{@vsn}",
        "Unified Development Documentation" => "https://crux.randomly.space/"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Crux.Rest.Application, []}
    ]
  end

  defp deps do
    [
      {:crux_structs, "~> 0.1.6"},
      {:httpoison, "~> 1.1.1"},
      {:timex, "~> 3.2.2"},
      {:poison, "~> 3.1.0"},
      {:ex_doc, git: "https://github.com/spaceeec/ex_doc", only: :dev, runtime: false}
    ]
  end
end
