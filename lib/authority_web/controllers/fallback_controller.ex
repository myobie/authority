defmodule AuthorityWeb.FallbackController do
  use AuthorityWeb, :controller

  def call(conn, {:error, :missing_access_token}) do
    conn
    |> put_status(401)
    |> json(%{error: "missing access token"})
  end

  def call(conn, {:error, :invalid_access_token}) do
    conn
    |> put_status(401)
    |> json(%{error: "invalid access token"})
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(500)
    |> json(%{error: error})
  end

  def call(conn, something) do
    conn
    |> put_status(500)
    |> json(%{error: IO.inspect(something)})
  end
end
