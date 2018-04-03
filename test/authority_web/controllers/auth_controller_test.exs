defmodule AuthorityWeb.AuthControllerTest do
  import ShorterMaps
  use AuthorityWeb.ConnCase
  alias Authority.Client
  import Authority.Factory

  test "GET /v1/authorize redirects", ~M{conn} do
    resp =
      get(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
  end

  test "POST /v1/authorize redirects", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
  end

  defp location_uri_params(conn) do
    case get_resp_header(conn, "location") do
      nil ->
        %{}

      [] ->
        %{}

      [url | _] ->
        url
        |> URI.parse()
        |> Map.get(:query)
        |> URI.decode_query()
    end
  end

  test "/v1/authorize must have scope param", ~M{conn} do
    resp =
      get(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "scope_is_a_required_param"
  end

  test "/v1/authorize must have openid in scope param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "invalid_scope"
  end

  test "/v1/authorize must have client_id param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 400
  end

  test "/v1/authorize must have a configured client_id param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "not a real client id",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 400
  end

  test "/v1/authorize must have a redirect_uri param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "redirect_uri_is_a_required_param"
  end

  test "/v1/authorize must have a matching redirect_uri param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "not a real redirect uri",
        "response_type" => "id_token",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "invalid_redirect_uri"
  end

  test "/v1/authorize must have response_type param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "response_type_is_a_required_param"
  end

  test "/v1/authorize must have a configured response_type for the current client param",
       ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "some other response type",
        "provider" => "github",
        "scope" => "openid email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "invalid_response_type"
  end

  test "/v1/authorize must have provider param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "scope" => "openid email"
      })

    assert resp.status == 500
    # For right now we are just showing a message, but eventually this should show a sign in page
  end

  test "/v1/authorize must have a configured provider for the current client param", ~M{conn} do
    resp =
      post(conn, "/v1/authorize", %{
        "client_id" => "test",
        "redirect_uri" => "https://www.example.com/auth-callback",
        "response_type" => "id_token",
        "provider" => "some unknown provider",
        "scope" => "openid email"
      })

    assert resp.status == 302
    assert location_uri_params(resp)["error"] == "invalid_provider"
  end

  test "POST /v1/token requires a correct grant type", ~M{conn} do
    {:ok, client} = Client.fetch("test")

    resp =
      post(conn, "/v1/token", %{
        "code" => "abc",
        "grant_type" => "bad_grant_type",
        "redirect_uri" => client.redirect_uri,
        "client_id" => client.client_id,
        "client_secret" => client.client_secret
      })

    assert json_response(resp, 400)
  end

  test "POST /v1/token code flow works", ~M{conn} do
    {:ok, client} = Client.fetch("test")
    req = insert(:authorization_request)

    resp =
      post(conn, "/v1/token", %{
        "code" => req.code,
        "grant_type" => "authorization_code",
        "redirect_uri" => client.redirect_uri,
        "client_id" => client.client_id,
        "client_secret" => client.client_secret
      })

    body = json_response(resp, 200)

    assert body["refresh_token"] == req.refresh_token
  end

  test "POST /v1/token refresh flow works", ~M{conn} do
    {:ok, client} = Client.fetch("test")
    req = insert(:authorization_request, claimed_at: Timex.now())

    resp =
      post(conn, "/v1/token", %{
        "grant_type" => "refresh_token",
        "refresh_token" => req.refresh_token,
        "client_id" => client.client_id,
        "client_secret" => client.client_secret
      })

    body = json_response(resp, 200)

    assert body["refresh_token"] != req.refresh_token
  end
end
