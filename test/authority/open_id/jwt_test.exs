defmodule Authority.OpenID.JWTTest do
  use Authority.DataCase

  alias Authority.OpenID.JWT

  test "can sign a map" do
    {_info, token} = JWT.Helpers.sign(%{email: "me@example.com"})
    assert String.contains?(token, ".")
  end

  test "can sign! a map" do
    token = JWT.Helpers.sign!(%{email: "me@example.com"})
    assert String.contains?(token, ".")
  end

  test "can verify that a token was signed by authority" do
    token = JWT.Helpers.sign!(%{email: "me@example.com"})
    assert JWT.Helpers.verify?(token)
  end

  test "can get to fields inside a token that was signed by authority" do
    token = JWT.Helpers.sign!(%{email: "me@example.com"})
    {true, fields} = JWT.Helpers.verify(token)
    assert fields["email"] == "me@example.com"
  end
end
