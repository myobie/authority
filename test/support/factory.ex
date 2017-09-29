defmodule Authority.Factory do
  use ExMachina.Ecto, repo: Authority.Repo

  def account_factory do
    %Authority.Account{
      name: "Nathan",
      preferred_username: "myobie"
    }
  end

  def email_factory do
    %Authority.Email{
      account: build(:account),
      address: sequence(:email_address, &"me-#{&1}@example.com"),
      verified: false
    }
  end

  def identity_factory do
    %Authority.Identity{
      account: build(:account),
      provider: "example",
      uid: "1",
      access_token: "abcdefg",
      scope: "",
      raw: %{"id" => 1}
    }
  end

  def website_factory do
    %Authority.Website{
      identity: build(:identity),
      url: "http://example.com"
    }
  end
end
