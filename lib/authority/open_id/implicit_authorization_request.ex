defmodule Authority.OpenID.ImplicitAuthorizationRequest do
  defstruct account: nil,
    email: nil,
    identity: nil,
    client: nil,
    nonce: nil,
    now: Timex.now(),
    claims: []

  alias Authority.OpenID.IDToken

  @type t :: %__MODULE__{}

  @expires_from_now [days: 2]

  @spec id_token(t, keyword) :: IDToken.t
  def id_token(req, from_now \\ @expires_from_now)

  def id_token(%{claims: ["email"], email: %{address: address}} = req, from_now) do
    req
    |> Map.put(:claims, %{})
    |> id_token(from_now)
    |> Map.put(:claims, %{email: address})
  end

  def id_token(req, from_now) do
    %IDToken{
      iss: "#{AuthorityWeb.Endpoint.url()}/",
      sub: req.account.id,
      aud: req.client.client_id,
      exp: req.now |> Timex.shift(from_now) |> Timex.to_unix(),
      iat: req.now |> Timex.to_unix(),
      auth_time: req.now |> Timex.to_unix(),
      nonce: req.nonce
    }
  end

  @spec signed_id_token(t) :: binary
  def signed_id_token(req) do
    req
    |> id_token()
    |> IDToken.sign!()
  end
end
