defmodule Authority.Email do
  use Authority.Schema

  @type t :: %__MODULE__{}

  schema "emails" do
    belongs_to :account, Authority.Account
    field :address, :string
    field :verified, :boolean
    timestamps()
  end

  @spec changeset(t, map, [account: Authority.Account.t]) :: Changeset.t
  def changeset(%__MODULE__{} = email \\ %__MODULE__{}, attrs, [account: account]) do
    email
    |> cast(attrs, [:address, :verified])
    |> update_change(:address, fn address ->
      address
      |> String.trim()
      |> String.downcase()
    end)
    |> unique_constraint(:address)
    |> put_assoc(:account, account)
    |> foreign_key_constraint(:account_id)
    |> validate_required([:address, :verified, :account])
    |> validate_length(:address, max: 1024)
  end

  @spec update_changeset(t, map) :: Changeset.t
  def update_changeset(%__MODULE__{} = email, attrs) do
    email
    |> cast(attrs, [:verified])
    |> validate_required([:verified])
  end
end
