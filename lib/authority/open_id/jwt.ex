defmodule Authority.OpenID.JWT do
  @callback sign(map) :: {map, binary}
  @callback sign!(map) :: binary
  @callback verify(binary) :: {true, map} | {false, term}
  @callback verify?(binary) :: boolean

  defmacro __using__(_) do
    quote do
      @behaviour Authority.OpenID.JWT
      alias Authority.OpenID.JWT.Helpers
    end
  end
end
