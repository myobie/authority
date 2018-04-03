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

config :mix_test_watch, clear: true

config :authority, Authority.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "authority_dev",
  hostname: "localhost",
  pool_size: 10

config :authority, :jwk, """
{"alg":"ES512","crv":"P-521","d":"DYfiP6tbDr9vACeb2hgGWkGsnX1zHFsnAQ7c-MnBfwHjQTFsQ4J-Uhw8GVEFcpd8w7UpjMjs9kb00K_Xx1S812s","kty":"EC","use":"sig","x":"AV4-9t1d1AFScL_GAGb4z__VjxT-1055-qpnapWoICIMvHTgiK-IyCiZ-PLPDKrsWHp7gxlt0DHbUzKtCkyG9U00","y":"AXTcUCXaXk2tqwTz9KdUt_r44cdvs2Y7NcUeivnQuQjHYyp5v8_7mX1n6-9S9Lr1Ve5VzshhfGWo8YGdPzDmfFjU"}
"""

config :authority, :clients, [
  %{
    client_id: "test",
    client_secret: "secret",
    redirect_uri: "https://www.example.com/auth-callback"
  },
  %{
    client_id: "test_again",
    client_secret: "secret_again",
    redirect_uri: "https://again.example.com/auth-callback",
    allowed_providers: [:github, :vso],
    allowed_response_types: [:code, :id_token]
  }
]

# import_config "dev.secret.exs"
