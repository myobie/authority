defmodule Authority.OpenID.ImplicitAuthorizationRequestTest do
  import ShorterMaps
  use Authority.DataCase
  alias Authority.Client
  alias Authority.OpenID.{ImplicitAuthorizationRequest, JWT}

  setup do
    account = insert(:account)
    identity = insert(:identity)
    {:ok, client} = Client.fetch("test")

    req = %ImplicitAuthorizationRequest{
      account: account,
      email: "me@example.com",
      identity: identity,
      client: client,
      nonce: "xyz",
      now: Timex.now()
    }

    {:ok, ~M{account, client, identity, req}}
  end

  test "makes an id_token", ~M{account, req} do
    token = ImplicitAuthorizationRequest.id_token(req)

    assert token.sub == account.id
    assert token.aud == "test"
  end

  test "makes a jwt for an id_token", ~M{req} do
    {:ok, jwt} = ImplicitAuthorizationRequest.signed_id_token(req)
    assert {true, _} = JWT.Helpers.verify(jwt)
  end
end
