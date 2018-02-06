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
      address: sequence(:email_address, &"me-#{&1}@example.com")
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

  def authorization_request_factory do
    %Authority.OpenID.AuthorizationRequest{
      client_id: "test",
      code: "abc",
      nonce: "xyz",
      refresh_token: "abcdefg",
      account: build(:account)
    }
  end

  def claimed_authorization_request_factory do
    build(:authorization_request, %{
      claimed_at: Timex.now()
    })
  end
end
