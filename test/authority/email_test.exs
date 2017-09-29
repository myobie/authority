defmodule Authority.EmailTest do
  use Authority.DataCase
  alias Authority.Email

  setup do
    account = insert(:account)
    {:ok, %{account: account}}
  end

  test "valid email", %{account: account} do
    changeset =
      params_for(:email)
      |> Email.changeset(account: account)

    assert changeset.valid?
  end
end
