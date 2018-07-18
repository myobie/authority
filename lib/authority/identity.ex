defmodule Authority.Identity do
  use Authority.Schema

  @type t :: %__MODULE__{}

  schema "identities" do
    belongs_to(:account, Authority.Account)
    field(:provider, :string)
    field(:uid, :string)
    field(:access_token, :string)
    field(:access_token_expires_at, :utc_datetime)
    field(:refresh_token, :string)
    field(:scope, :string, default: "")
    field(:raw, :map, default: %{})
    timestamps()
  end

  @spec changeset(map, account: Authority.Account.t()) :: Changeset.t()
  @spec changeset(t, map, account: Authority.Account.t()) :: Changeset.t()
  def changeset(%__MODULE__{} = identity \\ %__MODULE__{}, attrs, account: account) do
    identity
    |> cast(attrs, [
      :provider,
      :uid,
      :access_token,
      :access_token_expires_at,
      :refresh_token,
      :scope,
      :raw
    ])
    |> unique_constraint(:uid, name: "identities_provider_uid_index")
    |> put_assoc(:account, account)
    |> foreign_key_constraint(:account_id)
    |> validate_required([:account, :provider, :uid, :access_token, :raw])
    |> validate_length(:provider, max: 128)
    |> validate_length(:uid, max: 1024)
    |> validate_length([:access_token, :refresh_token], max: 8192)
    |> validate_length(:scope, max: 1024)
  end
end
