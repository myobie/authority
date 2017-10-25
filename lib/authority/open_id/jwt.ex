defmodule Authority.OpenID.JWT do
  @spec sign(map) :: {map, binary}
  def sign(jwt) do
    JOSE.JWT.sign(Authority.OpenID.rsa_private_key, jwt) |> JOSE.JWS.compact()
  end

  @spec sign!(map) :: binary
  def sign!(jwt), do: jwt |> sign() |> elem(1)

  @spec verify(binary) :: {true, map} | {false, term}
  def verify(compact_signed_jwt) do
    case JOSE.JWT.verify_strict(Authority.OpenID.rsa_public_key, ["PS256"], compact_signed_jwt) do
      {true, jwt, _jws} -> {true, jwt.fields}
      other -> other
    end
  end

  @spec verify?(binary) :: boolean
  def verify?(compact_signed_jwt), do: verify(compact_signed_jwt) |> elem(0)
end
