use Mix.Config

config :logger, level: :info

config :phoenix, :serve_endpoints, true

config :authority, AuthorityWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  # url: [scheme: "https", host: "authentication.example.com", port: 443],
  secret_key_base: "abcdxyz",
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:authority, :vsn)

config :authority, Authority.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "authority_prod",
  password: "password",
  database: "authority_prod",
  hostname: "database.example.com",
  pool_size: 10,
  ssl: true

config :authority, :jwk, "{}"

config :authority, :clients, []
