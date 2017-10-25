defmodule Authority.OpenID.AuthorizationRequest do
  defstruct account: nil,
    email: nil,
    identity: nil,
    client: nil,
    nonce: nil,
    now: Timex.now(),
    claims: %{}

  @type t :: %__MODULE__{}
end
