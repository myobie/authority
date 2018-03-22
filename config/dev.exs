use Mix.Config

config :authority, AuthorityWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :authority, AuthorityWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/authority_web/views/.*(ex)$},
      ~r{lib/authority_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :authority, Authority.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "authority_dev",
  hostname: "localhost",
  pool_size: 10

# import_config "dev.secret.exs"
