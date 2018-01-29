defmodule Authority.OpenID.JWT do
  @jwk_types ["PS512", "RS512", "ES512"]

  @spec sign(map) :: {map, binary}
  def sign(jwt) do
    JOSE.JWT.sign(Authority.OpenID.jwk, jwt) |> JOSE.JWS.compact()
  end

  @spec sign!(map) :: binary
  def sign!(jwt), do: jwt |> sign() |> elem(1)

  @spec verify(binary) :: {true, map} | {false, term}
  def verify(compact_signed_jwt) do
    case JOSE.JWT.verify_strict(Authority.OpenID.jwk, @jwk_types, compact_signed_jwt) do
      {true, jwt, _jws} -> {true, jwt.fields}
      other -> other
    end
  end

  @spec verify?(binary) :: boolean
  def verify?(compact_signed_jwt), do: verify(compact_signed_jwt) |> elem(0)
end
