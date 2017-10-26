defmodule Authority.ReleaseTasks do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def repos,
    do: Application.get_env(:authority, :ecto_repos, [])

  def boot_and_migrate do
    boot()
    migrate()
    stop()
  end

  def boot do
    :ok = Application.load(:authority)
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Enum.each(repos(), &(&1.start_link(pool_size: 1)))
  end

  def migrate,
    do: Enum.each(repos(), &run_migrations_for/1)

  def stop do
    IO.puts "Done."
    :init.stop()
  end

  def priv_dir(app),
    do: :code.priv_dir(app) |> to_string()

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts "Running migrations for #{app}..."
    Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
  end

  def migrations_path(repo),
    do: priv_path_for(repo, "migrations")

  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)
    repo_underscore = repo |> Module.split |> List.last |> Macro.underscore
    Path.join([priv_dir(app), repo_underscore, filename])
  end
end
