defmodule EisWeb.Router do
  use EisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Plug.UserSession
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EisWeb do
    pipe_through :browser

    live "/", JoinComponent, session: [:user_id]
    live "/setup", SetupComponent, session: [:user_id]
    live "/setname", NameComponent, session: [:user_id]
    live "/game", RouterComponent, session: [:user_id]
    resources "/debug", DebugController, only: [:index, :show]
  end


  # Other scopes may use custom stacks.
  # scope "/api", EisWeb do
  #   pipe_through :api
  # end
end
