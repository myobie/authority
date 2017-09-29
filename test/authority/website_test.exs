defmodule Authority.WebsiteTest do
  use Authority.DataCase
  alias Authority.Website

  setup do
    identity = insert(:identity)
    {:ok, %{identity: identity}}
  end

  test "valid website", %{identity: identity} do
    changeset =
      params_for(:website)
      |> Website.changeset(identity: identity)

    assert changeset.valid?
  end
end
