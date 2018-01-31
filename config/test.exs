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

config :authority, :jwk, """
{"alg":"ES512","crv":"P-521","d":"DYfiP6tbDr9vACeb2hgGWkGsnX1zHFsnAQ7c-MnBfwHjQTFsQ4J-Uhw8GVEFcpd8w7UpjMjs9kb00K_Xx1S812s","kty":"EC","use":"sig","x":"AV4-9t1d1AFScL_GAGb4z__VjxT-1055-qpnapWoICIMvHTgiK-IyCiZ-PLPDKrsWHp7gxlt0DHbUzKtCkyG9U00","y":"AXTcUCXaXk2tqwTz9KdUt_r44cdvs2Y7NcUeivnQuQjHYyp5v8_7mX1n6-9S9Lr1Ve5VzshhfGWo8YGdPzDmfFjU"}
"""
