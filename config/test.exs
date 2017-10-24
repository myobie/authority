use Mix.Config

config :authority, AuthorityWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :authority, Authority.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "authority_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
