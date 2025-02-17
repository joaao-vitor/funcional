defmodule TwitterWeb.UserView do
  use TwitterWeb, :view
  alias Twitter.User

  def first_name(%User{name: name}) do
    name |> String.split(" ") |> Enum.at(0)
  end
end
