use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :victor, VictorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :victor, Victor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "victor_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
