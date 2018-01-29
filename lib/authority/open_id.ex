defmodule Authority.OpenID do
  @jwk Application.get_env(:authority, :jwk) |> JOSE.JWK.from()
  @expires_from_now [days: 2]

  alias Authority.OpenID.{AuthorizationRequest, IDToken}

  def jwk, do: @jwk

  @spec id_token(AuthorizationRequest.t) :: IDToken.t
  def id_token(%{claims: ["email"], email: %{address: address}} = req) do
    req
    |> Map.put(:claims, %{})
    |> id_token()
    |> Map.put(:claims, %{email: address})
  end

  def id_token(req) do
    %IDToken{
      iss: "#{AuthorityWeb.Endpoint.url()}/",
      sub: req.account.id,
      aud: req.client.client_id,
      exp: req.now |> Timex.shift(@expires_from_now) |> Timex.to_unix(),
      iat: req.now |> Timex.to_unix(),
      auth_time: req.now |> Timex.to_unix(),
      nonce: req.nonce
    }
  end

  @spec signed_id_token(AuthorizationRequest.t) :: binary
  def signed_id_token(req) do
    req
    |> id_token()
    |> IDToken.sign!()
  end
end
