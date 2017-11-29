defmodule Authority.Mixfile do
  use Mix.Project

  def project do
    [
      app: :authority,
      version: version(),
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      dialyzer: [plt_add_deps: :transitive],
      aliases: aliases(),
      deps: deps()
    ]
  end

  @default_vsn "0.0.0"

  def version do
    case File.read("./VERSION") do
      {:ok, vsn} -> vsn |> String.trim()
      _ -> @default_vsn
    end
  end

  def application do
    [
      mod: {Authority.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:jose, "~> 1.8"},
      {:timex, "~> 3.1"},
      {:secure_random, "~> 0.5.1"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_github, "~> 0.4"},
      {:ueberauth_microsoft, "~> 0.3"},
      {:ueberauth_vsts, github: "myobie/ueberauth_vsts"},
      {:ex_machina, "~> 2.0", only: [:test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:distillery, "~> 1.5"},
      {:build_release, github: "myobie/build_release", only: [:dev]}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
