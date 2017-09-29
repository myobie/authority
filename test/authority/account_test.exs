defmodule Authority.AccountTest do
  use Authority.DataCase
  alias Authority.Account

  test "valid account" do
    changeset =
      params_for(:account)
      |> Account.changeset()

    assert changeset.valid?
  end
end
