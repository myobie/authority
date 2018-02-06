defmodule AuthorityWeb.AuthController do
  import ShorterMaps
  use AuthorityWeb, :controller

  # NOTE: To be able to have a single /authorize we are not using the Ueberauth plug directly
  @opts Ueberauth.init(base_path: "/v1/authorize")

  alias Authority.{Auth, Client, OpenID}
  require Logger

  action_fallback(AuthorityWeb.FallbackController)

  # TODO: actually support all of these scopes
  # @allowed_scopes ["address", "created_at", "email", "email_verified",
  #                  "family_name", "given_name", "identities", "name",
  #                  "nickname", "offline_access", "openid", "phone",
  #                  "picture", "profile"]
  @allowed_scopes ["email", "identities", "offline_access", "openid", "profile"]

  # TODO: actually support all of these types
  # @allowed_response_types ["code", "code id_token", "code token", "code id_token token",
  #                          "id_token", "token", "id_token token"]
  @allowed_response_types ["code", "id_token"]

  # we've found the client, let's go
  def authorize(%{assigns: ~M{client}} = conn, params) do
    state = params["state"]
    provider = params["provider"]

    with :ok <- validate_redirect_uri(client, params["redirect_uri"]),
         {:ok, scopes} <- validate_scopes(params["scope"]),
         :ok <- validate_provider(client, provider),
         {:ok, response_type} <- validate_response_type(client, params["response_type"]) do
      conn
      |> assign(:state, state)
      |> assign(:provider, provider)
      |> put_session("client_id", client.client_id)
      |> put_session("response_type", response_type)
      |> put_session("scopes", scopes)
      |> put_session("state", state)
      |> put_session("nonce", params["nonce"])
      |> to_provider()
    else
      {:error, error} ->
        uri =
          client.redirect_uri
          |> URI.parse()
          |> Map.put(:query, URI.encode_query(~M{error, state}))
          |> to_string()

        redirect(conn, external: uri)
    end
  end

  # we have the right params, let's find the client
  def authorize(conn, ~m{client_id} = params) do
    with {:ok, client} <- Client.fetch(client_id) do
      conn
      |> assign(:client, client)
      |> authorize(params)
    else
      {:error, :missing_client} ->
        conn
        |> put_status(400)
        |> text("Unsupported request")
    end
  end

  # no client and no params to find one :(
  def authorize(conn, _params) do
    conn
    |> put_status(400)
    |> text("Unsupported authorize request")
  end

  defp to_provider(%{assigns: %{provider: nil}} = conn) do
    conn
    |> put_status(500)
    |> text("TODO: Eventually this will be a sign in page with buttons for providers")
  end

  defp to_provider(%{assigns: ~M{provider}} = conn) do
    conn
    |> Map.put(:request_path, "/v1/authorize/#{provider}")
    |> Ueberauth.call(@opts)
    |> finish_redirect_to_provider()
  end

  # halted means Ueberauth decided to redirect somewhere
  defp finish_redirect_to_provider(%{halted: true} = conn), do: conn

  # else, let's go back to the client and let them know
  defp finish_redirect_to_provider(%{assigns: ~M{client, state}} = conn) do
    uri =
      client.redirect_uri
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(%{error: :invalid_provider, state: state}))
      |> to_string()

    redirect(conn, external: uri)
  end

  defp validate_redirect_uri(_client, nil) do
    {:error, :redirect_uri_is_a_required_param}
  end

  defp validate_redirect_uri(client, redirect_uri) do
    Client.redirect_uri_match?(client, redirect_uri)
  end

  @spec validate_scopes(String.t() | nil) :: {:ok, list(String.t())} | {:error, :invalid_scope | :scope_is_a_required_param}
  defp validate_scopes(nil), do: {:error, :scope_is_a_required_param}

  defp validate_scopes(scope) do
    scopes =
      scope
      |> String.split(" ", trim: true)
      |> MapSet.new()

    if MapSet.member?(scopes, "openid") && MapSet.subset?(scopes, MapSet.new(@allowed_scopes)) do
      {:ok, MapSet.to_list(scopes)}
    else
      {:error, :invalid_scope}
    end
  end

  @spec validate_response_type(Client.t(), String.t()) ::
          {:ok, String.t()} | {:error, :invalid_response_type | :response_type_is_a_required_param}
  defp validate_response_type(_client, nil) do
    {:error, :response_type_is_a_required_param}
  end

  defp validate_response_type(client, response_type) do
    sorted_response_type =
      response_type
      |> String.split(" ", trim: true)
      |> Enum.sort()
      |> Enum.join(" ")

    if Enum.member?(@allowed_response_types, sorted_response_type) &&
         Client.allowed_response_type?(client, sorted_response_type) do
      {:ok, sorted_response_type}
    else
      {:error, :invalid_response_type}
    end
  end

  @spec validate_provider(Client.t(), String.t() | atom) :: :ok | {:error, :invalid_provider}
  defp validate_provider(_client, nil), do: :ok

  defp validate_provider(client, provider) do
    if Client.allowed_provider?(client, provider) do
      :ok
    else
      {:error, :invalid_provider}
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    Logger.error("Authentication failure: #{inspect(fails)}")

    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    with {:ok, client_id} <- get_client_id_from_session(conn),
         {:ok, client} <- Client.fetch(client_id),
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
            claims: get_claims(get_session(conn, "scopes"))
          })

        "code" ->
          code_callback(conn, account, client)
      end
    end
  end

  def callback(%{assigns: %{attempted_ueberauth_call?: true}} = conn, _params) do
    # TODO: if we know the client, then redirect back to them
    conn
    |> put_status(400)
    |> json(%{error: "Request not supported"})
  end

  def callback(conn, params) do
    conn
    |> assign(:attempted_ueberauth_call?, true)
    |> Ueberauth.call(@opts)
    |> callback(params)
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

  defp get_client_id_from_session(conn) do
    with client_id when not is_nil(client_id) <- get_session(conn, "client_id") do
      {:ok, client_id}
    else
      _ -> {:error, :forgotten_original_client_destination}
    end
  end

  defp get_claims(scopes) do
    if Enum.member?(scopes, "email") do
      ["email"]
    else
      []
    end
  end

  def token(conn, %{
        "code" => code,
        "grant_type" => "authorization_code",
        "redirect_uri" => redirect_uri,
        "client_id" => client_id,
        "client_secret" => client_secret
      }) do
    with {:ok, token_response} <-
           OpenID.token_response(:code, code, client_id, client_secret, redirect_uri) do
      json(conn, token_response)
    end
  end

  def token(conn, %{
        "refresh_token" => refresh_token,
        "grant_type" => "refresh_token",
        "client_id" => client_id,
        "client_secret" => client_secret
      }) do
    with {:ok, token_response} <-
           OpenID.token_response(:refresh, refresh_token, client_id, client_secret) do
      json(conn, token_response)
    end
  end
end
