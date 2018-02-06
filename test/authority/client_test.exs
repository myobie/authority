defmodule Authority.ClientTest do
  use Authority.DataCase
  alias Authority.Client
  doctest Client

  test "fetches a client by client_id" do
    assert {:ok, _} = Client.fetch("test")
    assert {:error, _} = Client.fetch("missing")
  end
end
