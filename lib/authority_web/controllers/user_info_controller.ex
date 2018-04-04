defmodule AuthorityWeb.UserInfoController do
  use AuthorityWeb, :controller
  alias Authority.{Account, OpenID, Repo}

  def show(conn, _parmas) do
    # TOOO: check the scope to make sure it has profile
    # TODO: do we need to check to see if the request is still in the db?
    with {:ok, token} <- get_access_token(conn),
         {:ok, account} <- get_account(token) do
      # FIXME: will explode if there aren't any emails
      %{emails: [email | _]} = Repo.preload(account, :emails)

      render(conn, "show.json", account: account, email: email)
    end
  end

  defp get_account(token) do
    case Repo.get(Account, token.sub) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  defp get_access_token(conn) do
    with {:ok, token_string} <- get_access_token_header_value(conn) do
      case OpenID.AccessToken.verify(token_string) do
        {true, token} -> {:ok, token}
        _ -> {:error, :invalid_access_token}
      end
    end
  end

  defp get_access_token_header_value(conn) do
    case get_req_header(conn, "Authorization") do
      ["Bearer " <> value] -> {:ok, value}
      _ -> {:error, :missing_access_token}
    end
  end
end
