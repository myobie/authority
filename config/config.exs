use Mix.Config

config :victor,
  ecto_repos: [Victor.Repo]

config :victor, VictorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CBFL1okYX6SHw2kP+kLh8YaiC39BdmQ37V0ZwDtXJJAKg6EpgO5qjLMcTyvPSp6q",
  render_errors: [view: VictorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Victor.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "add to secret file",
  client_secret: "add to secret file"

import_config "#{Mix.env}.exs"
