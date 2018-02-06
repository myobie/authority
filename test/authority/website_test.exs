defmodule Authority.WebsiteTest do
  import ShorterMaps
  use Authority.DataCase
  alias Authority.Website

  setup do
    identity = insert(:identity)
    {:ok, ~M{identity}}
  end

  test "valid website", ~M{identity} do
    changeset =
      params_for(:website)
      |> Website.changeset(identity: identity)

    assert changeset.valid?
  end
end
