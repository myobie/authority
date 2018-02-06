defmodule Authority.OpenID.AccessToken do
  use Authority.OpenID.JWT

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

  def sign(access_token), do: access_token |> to_map() |> Helpers.sign()

  def sign!(access_token), do: access_token |> to_map() |> Helpers.sign!()

  def verify(compact_signed_jwt) do
    case Helpers.verify(compact_signed_jwt) do
      {true, jwt} -> {true, Enum.into(jwt, %__MODULE__{})}
      other -> other
    end
  end

  def verify?(compact_signed_jwt), do: Helpers.verify?(compact_signed_jwt)
end

defimpl Collectable, for: Authority.OpenID.AccessToken do
  @valid_keys %Authority.OpenID.AccessToken{}
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

           # ignore invalid keys
           true ->
             jwt
         end

       jwt, :done ->
         jwt

       _, :halt ->
         :ok
     end}
  end
end
