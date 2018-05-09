defmodule AuthorityWeb.IdentityController do
  use AuthorityWeb, :controller
  plug AuthorityWeb.PrefetchAccountPlug
  action_fallback AuthorityWeb.FallbackController

  alias Authority.Repo

  def index(%{assigns: %{account: account}} = conn, _params) do
    # TODO: check the scope to make sure it has identities

    %{identities: identities} = Repo.preload(account, :identities)

    render(conn, "index.json", identities: identities)
  end
end
