defmodule Authority.OpenIDTest do
  import ShorterMaps
  use Authority.DataCase

  alias Authority.{Client, OpenID, Repo}

  alias Authority.OpenID.{
    AccessToken,
    AuthorizationRequest,
    IDToken,
    ImplicitAuthorizationRequest,
    JWT
  }

  setup do
    {:ok, client} = Client.fetch("test")
    account = insert(:account)
    {:ok, ~M{client, account}}
  end

  defp get_query(%URI{} = uri, name) do
    uri
    |> Map.get(:query)
    |> URI.decode_query()
    |> Map.get(name)
  end

  defp get_query(uri, name) when is_binary(uri) do
    uri
    |> URI.parse()
    |> get_query(name)
  end

  test "creates an implicit callback response uri", ~M{client, account} do
    identity = insert(:identity, account: account)

    req = %ImplicitAuthorizationRequest{
      account: account,
      email: "me@example.com",
      identity: identity,
      client: client
    }

    {:ok, uri} = OpenID.implicit_callback_uri(req, "xyz")

    id_token = get_query(uri, "id_token")
    state = get_query(uri, "state")

    assert IDToken.verify?(id_token)
    assert state == "xyz"
  end

  test "creates a code callback response uri", ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")

    code = get_query(uri, "code")
    state = get_query(uri, "state")

    assert not is_nil(code)
    assert state == "xyz"
  end

  test "code callback response inserts an authorization request", ~M{client, account} do
    assert 0 == Repo.aggregate(AuthorizationRequest, :count, :id)
    {:ok, _} = OpenID.code_callback_uri(account, client, "xyz")
    assert 1 == Repo.aggregate(AuthorizationRequest, :count, :id)
  end

  test "token response for a code works", ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")
    code = get_query(uri, "code")

    {:ok, resp} =
      OpenID.token_response(
        :code,
        code,
        client.client_id,
        client.client_secret,
        client.redirect_uri
      )

    assert IDToken.verify?(resp.id_token)
    assert JWT.verify?(resp.access_token)
  end

  test "token response for a code claims the authorization request", ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")
    code = get_query(uri, "code")
    req = Repo.get_by(AuthorizationRequest, code: code)
    assert is_nil(req.claimed_at)

    {:ok, _} =
      OpenID.token_response(
        :code,
        code,
        client.client_id,
        client.client_secret,
        client.redirect_uri
      )

    req = Repo.get(AuthorizationRequest, req.id)
    assert not is_nil(req.claimed_at)
  end

  test "token response for a code fails if the client secret doesn't match",
       ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")
    code = get_query(uri, "code")

    {:error, _} =
      OpenID.token_response(:code, code, client.client_id, "nope", client.redirect_uri)
  end

  test "token response for a refresh token works", ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")

    {:ok, ~M{refresh_token}} =
      OpenID.token_response(
        :code,
        get_query(uri, "code"),
        client.client_id,
        client.client_secret,
        client.redirect_uri
      )

    {:ok, resp} =
      OpenID.token_response(:refresh, refresh_token, client.client_id, client.client_secret)

    assert IDToken.verify?(resp.id_token)
    assert JWT.verify?(resp.access_token)
  end

  test "token response for a refresh token deletes the old authorization request",
       ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")
    code = get_query(uri, "code")

    {:ok, ~M{refresh_token}} =
      OpenID.token_response(
        :code,
        code,
        client.client_id,
        client.client_secret,
        client.redirect_uri
      )

    req = Repo.get_by(AuthorizationRequest, code: code)

    {:ok, _} =
      OpenID.token_response(:refresh, refresh_token, client.client_id, client.client_secret)

    assert is_nil(Repo.get(AuthorizationRequest, req.id))
  end

  test "token response for a refresh token creates an already claimed authorization request",
       ~M{client, account} do
    {:ok, uri} = OpenID.code_callback_uri(account, client, "xyz")
    code = get_query(uri, "code")

    {:ok, ~M{refresh_token}} =
      OpenID.token_response(
        :code,
        code,
        client.client_id,
        client.client_secret,
        client.redirect_uri
      )

    {:ok, resp} =
      OpenID.token_response(:refresh, refresh_token, client.client_id, client.client_secret)

    access_token = AccessToken.verify(resp.access_token)
    # req is the id of the request that was created for it
    req = Repo.get(AuthorizationRequest, access_token.req)

    assert not is_nil(req.claimed_at)
  end
end
