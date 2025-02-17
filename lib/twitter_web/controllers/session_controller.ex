defmodule TwitterWeb.SessionController do
  use TwitterWeb, :controller

  alias Twitter.Repo
  alias TwitterWeb.Auth

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => password}}) do
    case Auth.login_by_username_and_pass(conn, user, password, repo: Repo) do
        {:ok, conn} ->
          conn
          |> put_flash(:info, "Bem vindo novamente!")
          |> redirect(to: Routes.page_path(conn, :index))
        {:error, _reason, conn} ->
          conn
          |> put_flash(:error, "Invalid username or password combination")
          |> render("new.html")
    end
  end

  def delete(conn, _) do
    #IO.inspect(conn)
    conn
    |> Auth.logout
    |> redirect(to: Routes.page_path(conn, :index))
    #|> put_flash(:info, "Peace Out")
    #|> redirect(to: "/")
  end
end
