use Mix.Config

config :authority,
  ecto_repos: [Authority.Repo]

config :authority, AuthorityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CBFL1okYX6SHw2kP+kLh8YaiC39BdmQ37V0ZwDtXJJAKg6EpgO5qjLMcTyvPSp6q",
  render_errors: [view: AuthorityWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Authority.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []},
    microsoft: {Ueberauth.Strategy.Microsoft, []},
    vso: {Ueberauth.Strategy.VSO, [default_scope: "vso.code_write"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "add to secret file",
  client_secret: "add to secret file"

config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  client_id: "add to secret file",
  client_secret: "add to secret file"

config :ueberauth, Ueberauth.Strategy.VSO.OAuth,
  client_id: "add to secret file",
  client_secret: "add to secret file"

config :authority, :rsa_keys, private: nil, public: nil
# One needs to generate a public/private key pair (JWK format) and add
# them to one of the secret.exs files
# TODO: document here how to generate a key pair

config :authority, :clients, []
# a client looks like:
#   %{client_id: "client-name",
#     client_secret: "abcxyz",
#     redirect_uri: "https://example.com/auth/callback"}

import_config "#{Mix.env}.exs"
