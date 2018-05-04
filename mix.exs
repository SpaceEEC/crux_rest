defmodule Crux.Rest.MixProject do
  use Mix.Project

  def project do
    [
      start_permanent: Mix.env() == :prod,
      package: package(),
      app: :crux_rest,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: "Package providing rest functions and rate limiting for the Discord API",
      source_url: "https://github.com/SpaceEEC/crux_rest/",
      homepage_url: "https://github.com/SpaceEEC/crux_rest/",
      deps: deps()
    ]
  end

  def package do
    [
      name: :crux_rest,
      licenses: ["MIT"],
      maintainers: ["SpaceEEC"],
      links: %{
        "GitHub" => "https://github.com/SpaceEEC/crux_rest/",
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
      {:httpoison, "~> 1.1.1"},
      {:timex, "~> 3.2.2"},
      {:poison, "~> 3.1.0"},
      {:crux_structs, "~> 0.1.1"},
      {:ex_doc, git: "https://github.com/spaceeec/ex_doc", only: :dev}
    ]
  end
end
