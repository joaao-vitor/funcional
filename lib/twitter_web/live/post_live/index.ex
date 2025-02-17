defmodule TwitterWeb.PostLive.Index do
  use TwitterWeb, :live_view
  alias Twitter.User
  alias Twitter.Repo
  alias Twitter.Timeline
  alias Twitter.Timeline.Post



  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket = assign(socket, :user_id, Map.get(session, "user_id"))
    {:ok, assign(socket, :posts, list_posts()), temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    loggedUser = Repo.get!(User, socket.assigns.user_id)
    post = Timeline.get_post!(id)

    if post.username == loggedUser.username do
      socket
      |> assign(:page_title, "Edit Post")
      |> assign(:post, post)
    else
      socket
      |> put_flash(:error, "Você não está autorizado para editar esse post.")
      |> push_redirect(to: "/posts")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do

    loggedUser = Repo.get!(User, socket.assigns.user_id)
    post = Timeline.get_post!(id)

    if post.username == loggedUser.username do
      post = Timeline.get_post!(id)
      {:ok, _} = Timeline.delete_post(post)

      {:noreply, assign(socket, :posts, list_posts())}
    end
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  defp list_posts do
    Timeline.list_posts()
  end
end
