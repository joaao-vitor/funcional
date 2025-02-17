defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TwitterWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TwitterWeb.Auth, repo: Twitter.Repo
  end

  pipeline :authenticated do
    plug :authenticate_user # Verifica se o usuário está autenticado
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  scope "/", TwitterWeb do
    pipe_through [:browser, :authenticated]

    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/:id/edit", PostLive.Index, :edit

    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/show/edit", PostLive.Show, :edit
  end


  scope "/", TwitterWeb do
    pipe_through :browser

    live "/", PageLive, :index

    resources "/users", UserController, only: [:index, :show, :new, :create, :edit, :delete, :update]
    get "/logout", LogoutController, :index
    resources "/sessions", SessionController, only: [:new, :create, :delete]

  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TwitterWeb.Telemetry
    end
  end
end
