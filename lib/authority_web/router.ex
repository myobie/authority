defmodule AuthorityWeb.Router do
  use AuthorityWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug :protect_from_forgery
    plug(:put_secure_browser_headers)
  end

  scope "/", AuthorityWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/v1", AuthorityWeb do
    pipe_through(:browser)

    get("/authorize", AuthController, :authorize, as: :authorize)
    post("/authorize", AuthController, :authorize)

    get("/authorize/:provider/callback", AuthController, :callback, as: :authorization_callback)
    post("/authorize/:provider/callback", AuthController, :callback)

    post("/token", AuthController, :token)
    delete("/logout", AuthController, :delete, as: :logout)

    get("/userinfo", UserInfoController, :show)
    post("/userinfo", UserInfoController, :show)

    get("/identities", IdentityController, :index)
  end
end
