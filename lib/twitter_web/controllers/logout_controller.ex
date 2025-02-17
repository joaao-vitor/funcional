defmodule TwitterWeb.LogoutController do
  use TwitterWeb, :controller
  alias TwitterWeb.Auth

  plug :authenticate_user when action in [:index]

  def index(conn, _params) do
    conn
    |> Auth.logout
    |> redirect(to: "/users/new")
  end

end
