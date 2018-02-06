defmodule Authority.OpenID.AuthorizationRequestTest do
  import ShorterMaps
  use Authority.DataCase
  alias Authority.OpenID.{AuthorizationRequest, JWT}

  setup do
    account = insert(:account)
    {:ok, ~M{account}}
  end

  test "valid changeset", ~M{account} do
    changeset =
      params_for(:authorization_request)
      |> AuthorizationRequest.changeset(account: account)

    assert changeset.valid?
  end

  test "makes an id_token", ~M{account} do
    req = insert(:authorization_request, account: account)
    token = AuthorizationRequest.id_token(req)

    assert token.sub == account.id
    assert token.aud == "test"
  end

  test "makes a jwt for an id_token", ~M{account} do
    req = insert(:authorization_request, account: account)
    {:ok, jwt} = AuthorizationRequest.signed_id_token(req)
    assert {true, _} = JWT.Helpers.verify(jwt)
  end

  test "makes an access_token", ~M{account} do
    req = insert(:authorization_request, account: account)
    token = AuthorizationRequest.access_token(req)

    assert token.sub == to_string(account.id)
    assert token.aud == "test"
  end

  test "makes a jwt for an access_token", ~M{account} do
    req = insert(:authorization_request, account: account)
    {:ok, jwt} = AuthorizationRequest.signed_access_token(req)
    assert {true, _} = JWT.Helpers.verify(jwt)
  end
end
