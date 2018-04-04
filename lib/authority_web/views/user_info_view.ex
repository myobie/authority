defmodule AuthorityWeb.UserInfoView do
  use AuthorityWeb, :view

  def render("show.json", %{account: account, email: email}) do
    %{
      sub: to_string(account.id),
      name: account.name,
      preferred_username: account.preferred_username,
      email: email.address,
      picture: account.avatar_url
    }
  end
end
