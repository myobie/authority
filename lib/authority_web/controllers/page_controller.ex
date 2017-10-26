defmodule AuthorityWeb.PageController do
  use AuthorityWeb, :controller

  def index(conn, _params) do
    text conn, "Welcome to Authority."
  end
end
