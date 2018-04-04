defmodule AuthorityWeb.UserInfoControllerTest do
  import ShorterMaps
  use AuthorityWeb.ConnCase

  alias Authority.OpenID
  import Authority.Factory

  setup ~M{conn} do
    account = insert(:account)
    req = insert(:claimed_authorization_request, account: account)
    email = insert(:email, account: account)

    {:ok, ~M{conn, account, req, email}}
  end

  test "GET /v1/userinfo requires an access token", ~M{conn} do
    resp = get(conn, "/v1/userinfo")
    assert resp.status == 401
  end

  test "POST /v1/userinfo requires an access token", ~M{conn} do
    resp = post(conn, "/v1/userinfo")
    assert resp.status == 401
  end

  test "GET /v1/userinfo works", ~M{conn, account, req, email} do
    {:ok, token} = OpenID.AuthorizationRequest.signed_access_token(req)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")

    resp = get(conn, "/v1/userinfo")
    body = json_response(resp, 200)

    assert body["sub"] == to_string(account.id)
    assert body["email"] == email.address
  end
end
