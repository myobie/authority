defmodule Authority.AuthTest do
  use Authority.DataCase

  @address "me@example.com"

  @github_auth %Ueberauth.Auth{
    credentials: %Ueberauth.Auth.Credentials{
      expires: false,
      scopes: ["public_repo", "user"],
      token: "abcxyz",
      token_type: "Bearer"
    },
    info: %Ueberauth.Auth.Info{
      email: @address,
      name: "Nathan",
      nickname: "myobie"
    },
    provider: :github,
    strategy: Ueberauth.Strategy.Github,
    uid: 179
  }

  test "can process an Auth struct from scratch" do
    result = Authority.Auth.process(@github_auth)

    assert match?({:ok,
      %{account: _account,
        email: _email,
        identity: _identity}},
      result)
  end

  test "can process an Auth struct with existing email" do
    insert(:email, address: @address)

    result = Authority.Auth.process(@github_auth)

    assert match?({:ok,
      %{account: _account,
        email: %{address: @address},
        identity: _identity}},
      result)

    # don't create a second account, but keeps the current one
    num_accounts = Repo.one(from a in Authority.Account, select: count(a.id))
    assert num_accounts == 1
  end

  test "can process an Auth struct with existing provider" do
    insert(:identity, uid: "179", provider: "github")

    result = Authority.Auth.process(@github_auth)

    assert match?({:ok,
      %{account: _account,
        email: _email,
        identity: _identity}},
      result)

    # don't create a second account, but keeps the current one
    num_accounts = Repo.one(from a in Authority.Account, select: count(a.id))
    assert num_accounts == 1
  end
end
