defmodule AuthorityWeb.PrefetchAccountPlug do
  import Plug.Conn

  alias Authority.{Account, OpenID, Repo}

  def init(options), do: options

  def call(conn, _options) do
    with {:ok, token} <- get_access_token(conn),
         {:ok, account} <- get_account(token) do
      assign(conn, :account, account)
    else
      error -> fallback(conn, error)
    end
  end

  def get_account(token) do
    case Repo.get(Account, token.sub) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  def get_access_token(conn) do
    with {:ok, token_string} <- get_access_token_header_value(conn) do
      case OpenID.AccessToken.verify(token_string) do
        {true, token} -> {:ok, token}
        _ -> {:error, :invalid_access_token}
      end
    end
  end

  def get_access_token_header_value(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> value] -> {:ok, value}
      _ -> {:error, :missing_access_token}
    end
  end

  def fallback(conn, error) do
    conn
    |> AuthorityWeb.FallbackController.call(error)
    |> halt()
  end
end
