defmodule AuthorityWeb.AuthController do
  require Logger

  use AuthorityWeb, :controller
  plug Ueberauth

  alias Authority.{Auth, Clients, OpenID}

  action_fallback AuthorityWeb.FallbackController

  def authorize(conn,
                %{"response_type" => "id_token",
                  "client_id" => client_id,
                  "redirect_uri" => redirect_uri,
                  "scope" => "openid profile",
                  "nonce" => nonce,
                  "provider" => provider} = params)
  do
    with {:ok, _client} <- Clients.fetch(client_id, redirect_uri) do
      conn
      |> put_session("nonce", nonce)
      |> put_session("client_id", client_id)
      |> put_session("redirect_uri", redirect_uri)
      |> put_session("state", params["state"])
      |> put_session("claims", params["claims"])
      |> redirect(to: "/auth/#{provider}") # TODO: validate the provider and allow clients to limit the providers they want to use
    end
  end

  def authorize(conn, _params) do
    conn
    |> put_status(404)
    |> json(%{error: "Request type not supported yet. Authority only supports response_type=id_token and scope=openid profile (Implicit flow with simple scope) right now."})
  end

  def request(_conn, _params) do
    raise "What do I do here?"
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    Logger.error "Authentication failure: #{inspect fails}"

    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    with {:ok, %{account: account, email: email, identity: identity}} <- Auth.process(auth),
      {:ok, client_id, redirect_uri} <- get_client_id_and_redirect_uri_from_session(conn),
      {:ok, client} <- Clients.fetch(get_session(conn, "client_id"), get_session(conn, "redirect_uri"))
    do
      req = %OpenID.AuthorizationRequest{
        account: account,
        email: email,
        identity: identity,
        client: client,
        nonce: get_session(conn, "nonce"),
        claims: get_claims(conn)
      }

      jwt = OpenID.signed_id_token(req)
      state = get_session(conn, "state")
      query = URI.encode_query(%{"id_token" => jwt, "state" => state})

      uri = client.redirect_uri
            |> URI.parse()
            |> Map.put(:query, query)
            |> to_string()

      conn
      |> configure_session(drop: true)
      |> redirect(external: uri)
    end
  end

  defp get_client_id_and_redirect_uri_from_session(conn) do
    with client_id when not is_nil(client_id) <- get_session(conn, "client_id"),
      redirect_uri when not is_nil(redirect_uri) <- get_session(conn, "redirect_uri")
    do
      {:ok, client_id, redirect_uri}
    else
      _ -> {:error, :forgotten_original_client_destination}
    end
  end

  defp get_claims(conn) do
    with claims_string when not is_nil(claims_string) <- get_session(conn, "claims"),
         {:ok, claims} <- Poison.decode(claims_string)
    do
      claims
    else
      _ -> %{}
    end
  end
end
