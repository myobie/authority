defmodule AuthorityWeb.IdentityControllerTest do
  import ShorterMaps
  use AuthorityWeb.ConnCase

  alias Authority.OpenID
  import Authority.Factory

  setup ~M{conn} do
    account = insert(:account)
    req = insert(:claimed_authorization_request, account: account)
    identity = insert(:identity, account: account)

    {:ok, ~M{conn, account, req, identity}}
  end

  test "GET /v1/identities requires an access token", ~M{conn} do
    resp = get(conn, "/v1/identities")
    assert resp.status == 401
  end

  test "GET /v1/identities works", ~M{conn, req, identity} do
    {:ok, token} = OpenID.AuthorizationRequest.signed_access_token(req)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")

    resp = get(conn, "/v1/identities")
    body = json_response(resp, 200)

    assert length(body) == 1

    identity_json = List.first(body)
    assert identity_json["provider"] == identity.provider
    assert identity_json["uid"] == identity.uid
  end
end
