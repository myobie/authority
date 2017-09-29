defmodule AuthorityWeb.AuthController do
  require Logger

  use AuthorityWeb, :controller
  plug Ueberauth

  def request(_conn, _params) do
    raise "What do I do here?"
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    Logger.debug inspect(auth)

    conn
    |> redirect(to: "/")

    # case Authority.Accounts.upsert(auth) do
    #   {:ok, account} ->
    #     conn
    #     |> put_flash(:info, "Successfully authenticated.")
    #     |> put_session(:current_account, account)
    #     |> redirect(to: "/")
    #   {:error, reason} ->
    #     conn
    #     |> put_flash(:error, reason)
    #     |> redirect(to: "/")
    # end
  end
end
