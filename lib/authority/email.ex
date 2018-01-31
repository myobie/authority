defmodule Authority.Email do
  use Authority.Schema

  @type t :: %__MODULE__{}

  schema "emails" do
    belongs_to(:account, Authority.Account)
    field(:address, :string)
    timestamps()
  end

  def format(address) do
    address
    |> String.trim()
    |> String.downcase()
  end

  @spec changeset(t, map, account: Authority.Account.t()) :: Changeset.t()
  def changeset(%__MODULE__{} = email \\ %__MODULE__{}, attrs, account: account) do
    email
    |> cast(attrs, [:address])
    |> update_change(:address, &format/1)
    |> unique_constraint(:address)
    |> put_assoc(:account, account)
    |> foreign_key_constraint(:account_id)
    |> validate_required([:address, :account])
    |> validate_length(:address, max: 1024)
  end
end
