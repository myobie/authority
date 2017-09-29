defmodule Authority.IdentityTest do
  use Authority.DataCase
  alias Authority.Identity

  setup do
    account = insert(:account)
    {:ok, %{account: account}}
  end

  test "valid identity", %{account: account} do
    changeset =
      params_for(:identity)
      |> Identity.changeset(account: account)

    assert changeset.valid?
  end
end
