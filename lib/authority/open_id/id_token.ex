defmodule Authority.OpenID.IDToken do
  alias Authority.OpenID.JWT

  defstruct iss: nil,
            sub: nil,
            aud: nil,
            exp: nil,
            iat: nil,
            auth_time: nil,
            nonce: nil,
            claims: %{}

  @type t :: %__MODULE__{}

  def to_map(id_token) do
    id_token
    |> Map.from_struct()
    |> Map.delete(:claims)
    |> Map.merge(id_token.claims)
  end

  def sign(id_token), do: id_token |> to_map() |> JWT.sign()

  def sign!(id_token), do: id_token |> to_map() |> JWT.sign!()

  def verify(compact_signed_jwt) do
    case JWT.verify(compact_signed_jwt) do
      {true, jwt} -> jwt |> Enum.into(%__MODULE__{})
      other -> other
    end
  end

  def verify?(compact_signed_jwt), do: JWT.verify?(compact_signed_jwt)
end

defimpl Collectable, for: Authority.OpenID.IDToken do
  @valid_keys %Authority.OpenID.IDToken{}
              |> Map.from_struct()
              |> Map.keys()
              |> List.delete(:__struct__)
              |> Enum.into(Map.new(), fn v -> {to_string(v), v} end)

  def into(original) do
    {original,
     fn
       jwt, {:cont, {k, v}} ->
         cond do
           Map.has_key?(@valid_keys, k) ->
             Map.put(jwt, Map.get(@valid_keys, k), v)

           # invalid keys go into claims
           true ->
             %{jwt | claims: Map.put(jwt.claims, k, v)}
         end

       jwt, :done ->
         jwt

       _, :halt ->
         :ok
     end}
  end
end
