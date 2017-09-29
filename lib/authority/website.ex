defmodule Authority.Website do
  use Authority.Schema

  @type t :: %__MODULE__{}

  schema "websites" do
    belongs_to :identity, Authority.Identity
    field :url, :string
  end

  @spec changeset(map, [identity: Authority.Identity.t]) :: Changeset.t
  @spec changeset(t, map, [identity: Authority.Identity.t]) :: Changeset.t
  def changeset(%__MODULE__{} = website \\ %__MODULE__{}, attrs, [identity: identity]) do
    website
    |> cast(attrs, [:url])
    |> put_assoc(:identity, identity)
    |> foreign_key_constraint(:identity_id)
    |> validate_required([:url])
    |> validate_length(:url, max: 2048)
  end
end
