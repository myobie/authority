defmodule Authority.OpenID.AccessToken do
  alias Authority.OpenID.JWT

  defstruct iss: nil,
            aud: nil,
            exp: nil,
            iat: nil,
            sub: nil,
            req: nil,
            scp: ["api"]

  @type t :: %__MODULE__{}

  def to_map(access_token) do
    access_token
    |> Map.from_struct()
  end

  def sign(access_token),
    do: access_token |> to_map() |> JWT.sign()

  def sign!(access_token),
    do: access_token |> to_map() |> JWT.sign!()

  def verify(compact_signed_jwt) do
    case JWT.verify(compact_signed_jwt) do
      {true, jwt} -> jwt |> Enum.into(%__MODULE__{})
      other -> other
    end
  end

  def verify?(compact_signed_jwt),
    do: JWT.verify?(compact_signed_jwt)
end
