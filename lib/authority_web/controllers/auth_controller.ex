defmodule AuthorityWeb.AuthController do
  require Logger

  use AuthorityWeb, :controller
  plug Ueberauth

  alias Authority.{Auth, Clients, OpenID}

  action_fallback AuthorityWeb.FallbackController

  def authorize(conn, %{"client_id" => client_id,
                        "redirect_uri" => redirect_uri,
                        "response_type" => response_type,
                        "provider" => provider} = params) when response_type in ["id_token", "code"] do
    with {:ok, _client} <- Clients.fetch(client_id, redirect_uri) do
      conn
      |> put_session("client_id", client_id)
      |> put_session("redirect_uri", redirect_uri)
      |> put_session("response_type", response_type)
      |> put_session("scope", params["scope"])
      |> put_session("state", params["state"])
      |> put_session("nonce", params["nonce"])
      |> redirect(to: "/auth/#{provider}") # TODO: validate the provider and allow clients to limit the providers they want to use
    end
  end

  def authorize(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Request not supported"})
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
    with {:ok, client_id, redirect_uri} <- get_client_id_and_redirect_uri_from_session(conn),
         {:ok, client} <- Clients.fetch(client_id, redirect_uri),
         {:ok, %{account: account, email: email, identity: identity}} <- Auth.process(auth) do
      case get_session(conn, "response_type") do
        nil ->
          conn
          |> put_status(400)
          |> json(%{error: "Request not supported"})
        "id_token" ->
          implicit_callback(conn, %OpenID.ImplicitAuthorizationRequest{
            account: account,
            email: email,
            identity: identity,
            client: client,
            nonce: get_session(conn, "nonce"),
            claims: get_claims(get_session(conn, "scope"))
          })
        "code" ->
          code_callback(conn, account, client)
      end
    end
  end

  defp implicit_callback(conn, req) do
    with {:ok, uri} <- OpenID.implicit_callback_uri(req, get_session(conn, "state")) do
      conn
      |> configure_session(drop: true)
      |> redirect(external: uri)
    end
  end

  defp code_callback(conn, account, client) do
    with {:ok, uri} <- OpenID.code_callback_uri(account, client, get_session(conn, "state")) do
      conn
      |> configure_session(drop: true)
      |> redirect(external: uri)
    end
  end

  defp get_client_id_and_redirect_uri_from_session(conn) do
    with client_id when not is_nil(client_id) <- get_session(conn, "client_id"),
         redirect_uri when not is_nil(redirect_uri) <- get_session(conn, "redirect_uri") do
      {:ok, client_id, redirect_uri}
    else
      _ -> {:error, :forgotten_original_client_destination}
    end
  end

  defp get_claims(scope) do
    if String.contains?(scope, "email") do
      ["email"]
    else
      []
    end
  end

  def token(conn, %{"code" => code, "grant_type" => "authorization_code", "redirect_uri" => redirect_uri, "client_id" => client_id, "client_secret" => client_secret}) do
    with {:ok, token_response} <- OpenID.token_response(:code, code, client_id, client_secret, redirect_uri) do
      json(conn, token_response)
    end
  end

  def token(conn, %{"refresh_token" => refresh_token, "grant_type" => "refresh_token", "redirect_uri" => redirect_uri, "client_id" => client_id, "client_secret" => client_secret}) do
    with {:ok, token_response} <- OpenID.token_response(:refresh, refresh_token, client_id, client_secret, redirect_uri) do
      json(conn, token_response)
    end
  end
end
