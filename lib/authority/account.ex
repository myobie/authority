defmodule Authority.Account do
  use Authority.Schema

  schema "accounts" do
    field(:name, :string)
    field(:preferred_username, :string)
    field(:avatar_url, :string)
    field(:timezone, :string)

    belongs_to(:primary_email, Authority.Email)
    belongs_to(:primary_website, Authority.Website)

    has_many(:emails, Authority.Email)
    has_many(:identities, Authority.Identity)

    timestamps()
  end

  @type t :: %__MODULE__{}

  @spec changeset(map) :: Changeset.t()
  @spec changeset(t, map) :: Changeset.t()
  def changeset(%__MODULE__{} = account \\ %__MODULE__{}, attrs) do
    account
    |> cast(attrs, [:name, :preferred_username, :avatar_url, :timezone])
    |> cast_assoc(:primary_email)
    |> cast_assoc(:primary_website)
    |> foreign_key_constraint(:primary_email_id)
    |> foreign_key_constraint(:primary_website_id)
    |> validate_length(:name, max: 256)
    |> validate_length(:preferred_username, max: 128)
    |> validate_length(:avatar_url, max: 1024)
    |> validate_length(:timezone, max: 128)
  end
end
