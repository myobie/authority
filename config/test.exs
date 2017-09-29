use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :authority, AuthorityWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :authority, Authority.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "authority_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
