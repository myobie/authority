defmodule Authority.ClientTest do
  use Authority.DataCase
  alias Authority.Client
  doctest Client

  test "fetches a client by client_id" do
    assert {:ok, _} = Client.fetch("test")
    assert {:error, _} = Client.fetch("missing")
  end

  test "fetches a client by client_id and redirect_uri" do
    assert {:ok, _} = Client.fetch("test", "https://www.example.com/auth-callback")
    assert {:error, _} = Client.fetch("missing", "https://www.example.com/auth-callback")
    assert {:error, _} = Client.fetch("test", "https://example.com/auth-callback")
  end
end
