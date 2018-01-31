defmodule Authority.OpenID.AuthorizationRequest do
  use Authority.Schema
  alias Authority.Account
  alias Authority.OpenID.{AccessToken, IDToken}

  schema "authorization_requests" do
    field(:client_id, :string)
    field(:code, :string)
    field(:nonce, :string)
    field(:refresh_token, :string)
    field(:claimed_at, :naive_datetime)

    belongs_to(:account, Account)

    timestamps()
  end

  @type t :: %__MODULE__{}
  @type opts :: [account: Account.t()]

  @expires_from_now [days: 2]
  @required_attributes [:client_id, :code, :refresh_token]

  @spec changeset(map, opts) :: Changeset.t() | no_return
  @spec changeset(t | Changeset.t(), map, opts) :: Changeset.t() | no_return
  def changeset(struct \\ %__MODULE__{}, params, account: account) do
    struct
    |> cast(params, @required_attributes ++ [:nonce])
    |> validate_required(@required_attributes)
    |> put_assoc(:account, account)
  end

  @spec claim_changeset(t) :: Changeset.t() | no_return
  def claim_changeset(request) do
    change(request, %{claimed_at: Timex.now()})
  end

  @spec id_token(t, keyword) :: IDToken.t()
  def id_token(req, from_now \\ @expires_from_now) do
    %IDToken{
      iss: "#{AuthorityWeb.Endpoint.url()}/",
      sub: req.account_id,
      aud: req.client_id,
      exp: req.inserted_at |> Timex.shift(from_now) |> Timex.to_unix(),
      iat: req.inserted_at |> Timex.to_unix(),
      auth_time: req.inserted_at |> Timex.to_unix(),
      nonce: req.nonce
    }
  end

  @spec signed_id_token(t, keyword) :: {:ok, binary}
  def signed_id_token(req, from_now \\ @expires_from_now) do
    {:ok,
     req
     |> id_token(from_now)
     |> IDToken.sign!()}
  end

  def access_token(req, from_now \\ @expires_from_now) do
    %AccessToken{
      iss: "#{AuthorityWeb.Endpoint.url()}/",
      aud: req.client_id,
      exp: req.inserted_at |> Timex.shift(from_now) |> Timex.to_unix(),
      iat: req.inserted_at |> Timex.to_unix(),
      sub: to_string(req.account_id),
      req: to_string(req.id)
    }
  end

  def signed_access_token(req, from_now \\ @expires_from_now) do
    {:ok,
     req
     |> access_token(from_now)
     |> AccessToken.sign!()}
  end
end
