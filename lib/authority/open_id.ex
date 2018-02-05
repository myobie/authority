defmodule Authority.OpenID do
  @jwk Application.get_env(:authority, :jwk) |> JOSE.JWK.from()
  def jwk, do: @jwk

  alias Authority.{Client, Repo}
  alias Authority.OpenID.{AuthorizationRequest, ImplicitAuthorizationRequest}
  import Ecto.Query

  @spec implicit_callback_uri(ImplicitAuthorizationRequest.t(), String.t()) :: {:ok, String.t()}
  def implicit_callback_uri(%ImplicitAuthorizationRequest{} = req, state) do
    jwt = ImplicitAuthorizationRequest.signed_id_token(req)
    query = URI.encode_query(%{"id_token" => jwt, "state" => state})

    uri =
      req.client.redirect_uri
      |> URI.parse()
      |> Map.put(:query, query)
      |> to_string()

    {:ok, uri}
  end

  def code_callback_uri(account, client, state) do
    with {:ok, req} <- insert_authorization_request(account, client) do
      query = URI.encode_query(%{"code" => req.code, "state" => state})

      uri =
        client.redirect_uri
        |> URI.parse()
        |> Map.put(:query, query)
        |> to_string()

      {:ok, uri}
    end
  end

  defp insert_authorization_request(account, client) do
    authorization_request_changeset(account, client)
    |> Repo.insert()
  end

  defp refresh_authorization_request(old_req) do
    with {:ok, client} <- Client.fetch(old_req.client_id),
         old_req = Repo.preload(old_req, :account),
         {:ok, new_req} <- insert_authorization_request(old_req.account, client),
         {:ok, new_req} <- claim_authorization_request(new_req),
         {:ok, _} <- Repo.delete(old_req) do
      {:ok, new_req}
    end
  end

  defp authorization_request_changeset(account, client) do
    AuthorizationRequest.changeset(
      %{
        client_id: client.client_id,
        code: SecureRandom.urlsafe_base64(128) |> String.trim_trailing("="),
        refresh_token: SecureRandom.urlsafe_base64(128) |> String.trim_trailing("=")
      },
      account: account
    )
  end

  def token_response(:code, code, client_id, client_secret, redirect_uri) do
    from_now = [days: 2]

    with {:ok, client} <- Client.fetch(client_id, redirect_uri),
         :ok <- Client.secret_match?(client, client_secret),
         {:ok, req} <- fetch_authorization_request_by_code_and_client_id(code, client_id),
         {:ok, req} <- claim_authorization_request(req),
         {:ok, id_token} <- AuthorizationRequest.signed_id_token(req, from_now),
         {:ok, access_token} <- AuthorizationRequest.signed_access_token(req, from_now),
         expires_in = Timex.now() |> Timex.shift(from_now) |> Timex.to_unix() do
      {:ok,
       %{
         id_token: id_token,
         access_token: access_token,
         refresh_token: req.refresh_token,
         expires_in: expires_in
       }}
    end
  end

  def token_response(:refresh, refresh_token, client_id, client_secret) do
    from_now = [days: 2]

    with {:ok, client} <- Client.fetch(client_id),
         :ok <- Client.secret_match?(client, client_secret),
         {:ok, old_req} <-
           fetch_authorization_request_by_refresh_token_and_client_id(refresh_token, client_id),
         {:ok, new_req} <- refresh_authorization_request(old_req),
         {:ok, id_token} <- AuthorizationRequest.signed_id_token(new_req, from_now),
         {:ok, access_token} <- AuthorizationRequest.signed_access_token(new_req, from_now),
         expires_in = Timex.now() |> Timex.shift(from_now) |> Timex.to_unix() do
      {:ok,
       %{
         id_token: id_token,
         access_token: access_token,
         refresh_token: new_req.refresh_token,
         expires_in: expires_in
       }}
    end
  end

  # codes are good for 30 minutes and can only be used once
  defp fetch_authorization_request_by_code_and_client_id(code, client_id) do
    thirty_minutes_ago = Timex.shift(Timex.now(), minutes: -30)

    query =
      from(
        a in AuthorizationRequest,
        where: a.code == ^code,
        where: a.client_id == ^client_id,
        where: is_nil(a.claimed_at),
        where: a.inserted_at > ^thirty_minutes_ago,
        preload: [:account]
      )

    Repo.one(query)
  end

  # refresh tokens are good for 30 days, can only be used once, and can only be used if the original code was claimed
  defp fetch_authorization_request_by_refresh_token_and_client_id(refresh_token, client_id) do
    thirty_days_ago = Timex.shift(Timex.now(), days: -30)

    query =
      from(
        a in AuthorizationRequest,
        where: a.refresh_token == ^refresh_token,
        where: a.client_id == ^client_id,
        where: a.claimed_at > ^thirty_days_ago,
        preload: [:account]
      )

    Repo.one(query)
  end

  defp claim_authorization_request(request) do
    request
    |> AuthorizationRequest.claim_changeset()
    |> Repo.update()
  end
end
