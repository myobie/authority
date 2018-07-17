defmodule Authority.Repo.Migrations.IncreaseTokenSizes do
  use Ecto.Migration

  def change do
    alter table(:identities) do
      modify(:provider, :string, null: false, size: 128)
      modify(:uid, :string, null: false, size: 1024)
      modify(:access_token, :string, null: false, size: 8192)
      modify(:refresh_token, :string, size: 8192)
    end
  end
end
