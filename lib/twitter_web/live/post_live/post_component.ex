defmodule TwitterWeb.PostLive.PostComponent do
  alias Twitter.User
  alias Twitter.Repo
  use TwitterWeb, :live_component

  def render(assigns) do
    loggedUser = Repo.get(User, assigns.user_id)
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <div class="row">
        <div class="column">
          <div class="post-avatar">
            <img src="https://avatarfiles.alphacoders.com/103/103373.png" height="32" alt="<%= @post.username %>">
          </div>
        </div>
        <div class="column column-90 post-body">
          <b>@<%= @post.username %></b>
          <br/>
          <%= @post.body %>
        </div>
      </div>

      <div class="row actions">
        <div class="column">
          <a href="#" phx-click="like" phx-target="<%= @myself %>">
            <i class="fa fa-heart like"></i> <%= @post.likes_count %>
          </a>
        </div>
        <div class="column">
          <a href="#" phx-click="repost" phx-target="<%= @myself %>">
            <i class="fa fa-retweet retweet"></i> <%= @post.reposts_count %>
          </a>
        </div>
        <%= if loggedUser.username === assigns.post.username do %>
        <div class="column delete-edit">
          <%= live_patch to: Routes.post_index_path(@socket, :edit, @post.id) do %>
            <i class="fa fa-edit edit"></i>
          <% end %>
          <%= link to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Remover?"] do %>
            <i class="fa fa-trash delete" onclick="carrega()"></i>
          <% end %>
        </div>
        <% end %>
      </div>
    </div>
    """
  end
  def handle_event("like", _, socket) do
    Twitter.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end
  def handle_event("repost", _, socket) do
    Twitter.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end
end
