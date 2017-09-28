defmodule Victor.Repo.Migrations.AddAccountsEmailsAndIdentitiesTables do
  use Victor.Migration

  def change do
    create table(:accounts) do
      add :name, :string, size: 256
      add :preferred_username, :string, size: 128
      add :avatar_url, :string, size: 1024
      add :timezone, :string, size: 128
      timestamps()
    end

    create table(:emails) do
      add :address, :string, size: 1024, null: false
      add :verified, :boolean, null: false
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:emails, :address)
    create index(:emails, :account_id)

    alter table(:accounts) do
      add :primary_email_id, references(:emails, on_delete: :nilify_all)
    end

    create index(:accounts, :primary_email_id)

    create table(:identities) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :provider, :string, null: false, size: 64
      add :uid, :string, null: false, size: 256
      add :access_token, :string, null: false, size: 2048
      add :access_token_expires_at, :utc_datetime
      add :refresh_token, :string, size: 2048
      add :scope, :string, default: "", null: false, size: 1024
      add :raw, :map, default: %{}, null: false
      timestamps()
    end

    create unique_index(:identities, [:provider, :uid], name: "identities_provider_uid_index")

    create table(:websites) do
      add :identity_id, references(:identities, on_delete: :delete_all), null: false
      add :url, :string, size: 2048
      timestamps()
    end

    create index(:websites, :identity_id)

    alter table(:accounts) do
      add :primary_website_id, references(:websites, on_delete: :nilify_all)
    end
  end
end
