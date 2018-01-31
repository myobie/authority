defmodule Authority.Repo.Migrations.CreateAuthorizationRequest do
  use Authority.Migration

  def change do
    create table(:authorization_requests) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :client_id, :string, null: false
      add :nonce, :string
      add :code, :string, null: false
      add :refresh_token, :string, null: false
      add :claimed_at, :naive_datetime, null: true

      timestamps()
    end

    create index(:authorization_requests, [:account_id])
    create index(:authorization_requests, [:code, :client_id, :inserted_at])
    create index(:authorization_requests, [:code, :client_id, :claimed_at])
    create index(:authorization_requests, [:refresh_token, :client_id, :claimed_at])
  end
end
