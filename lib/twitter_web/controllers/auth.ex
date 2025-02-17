defmodule TwitterWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  import Bcrypt, only: [verify_pass: 2, no_user_verify: 0]
  alias Twitter.User
  alias TwitterWeb.Router.Helpers, as: Routes

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(User, user_id)
    assign(conn, :current_user, user)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "Você deve estar logado para ter acesso nesta página!")
      |> redirect(to: Routes.user_path(conn, :new))
      |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, username: username)

    cond do
      user && Bcrypt.verify_pass(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}

      user ->
        {:error, :unauthorized, conn}

      true ->
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    conn |> configure_session(drop: true)
  end

  def get_user_by_id(user_id) do
    case user_id do
      nil -> {:error, :unauthorized}
      user_id ->
        user = Repo.get(User, user_id)
        if user, do: {:ok, user}, else: {:error, :not_found}
    end
  end
end
