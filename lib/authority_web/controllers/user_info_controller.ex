defmodule AuthorityWeb.UserInfoController do
  use AuthorityWeb, :controller
  plug AuthorityWeb.PrefetchAccountPlug
  action_fallback AuthorityWeb.FallbackController

  alias Authority.Repo

  def show(%{assigns: %{account: account}} = conn, _parmas) do
    # TOOO: check the scope to make sure it has profile
    # TODO: do we need to check to see if the request is still in the db?

    %{emails: [email | _]} = Repo.preload(account, :emails)

    render(conn, "show.json", account: account, email: email)
  end

end
