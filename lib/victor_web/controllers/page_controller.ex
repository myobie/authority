defmodule VictorWeb.PageController do
  use VictorWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
