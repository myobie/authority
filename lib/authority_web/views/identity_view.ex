defmodule AuthorityWeb.IdentityView do
  use AuthorityWeb, :view

  def render("index.json", %{identities: identities}) do
    render_many(identities, __MODULE__, "show.json")
  end

  def render("show.json", %{identity: identity}) do
    %{
      provider: identity.provider,
      uid: identity.uid,
      access_token: identity.access_token,
      access_token_expires_at: identity.access_token_expires_at,
      scope: identity.scope
    }
  end
end
