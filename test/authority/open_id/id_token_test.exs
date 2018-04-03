defmodule Authority.OpenID.IDTokenTest do
  use Authority.DataCase

  alias Authority.OpenID.{IDToken, JWT}

  test "is collectable" do
    info = %{
      "iss" => "iss",
      "sub" => "sub",
      "aud" => "aud",
      "exp" => "exp",
      "iat" => "iat",
      "auth_time" => "auth_time",
      "nonce" => "nonce",
      "another_key" => "should end up in claims"
    }

    token = Enum.into(info, %IDToken{})

    assert token.iss == "iss"
    assert token.sub == "sub"
    assert token.aud == "aud"
    assert token.exp == "exp"
    assert token.iat == "iat"
    assert token.auth_time == "auth_time"
    assert token.nonce == "nonce"
    assert token.claims == %{"another_key" => "should end up in claims"}
  end

  test "puts claims as keys in the token" do
    token = %IDToken{
      iss: "iss",
      sub: "sub",
      aud: "aud",
      exp: "exp",
      iat: "iat",
      auth_time: "auth_time",
      nonce: "nonce",
      claims: %{another_key: "should end up outside claims"}
    }

    jwt = IDToken.sign!(token)

    {true, info} = JWT.Helpers.verify(jwt)

    assert info["iss"] == "iss"
    assert info["sub"] == "sub"
    assert info["aud"] == "aud"
    assert info["exp"] == "exp"
    assert info["iat"] == "iat"
    assert info["auth_time"] == "auth_time"
    assert info["nonce"] == "nonce"
    assert info["another_key"] == "should end up outside claims"
    assert is_nil(info["claims"])
    assert is_nil(info[:claims])
  end
end
