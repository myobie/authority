defmodule Authority.OpenID.AccessTokenTest do
  use Authority.DataCase

  alias Authority.OpenID.AccessToken

  test "is collectable" do
    info = %{
      "iss" => "iss",
      "aud" => "aud",
      "exp" => "exp",
      "iat" => "iat",
      "sub" => "sub",
      "req" => "req",
      "scp" => "scp",
      "will_be_ignored" => "?"
    }

    token = Enum.into(info, %AccessToken{})

    assert token.iss == "iss"
    assert token.aud == "aud"
    assert is_nil(Map.get(token, :will_be_ignored))
    assert is_nil(Map.get(token, "will_be_ignored"))
  end
end
