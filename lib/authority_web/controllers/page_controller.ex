defmodule AuthorityWeb.PageController do
  use AuthorityWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
