defmodule ChatWeb.User do
  alias Chat.Repo
  @moduledoc """
    module contains some logic regarding users
  """
  @doc """
  basically creates a message struct
  """
  def create_user(username),
      do: %Chat.User{
        username: username
      }
  def save_user(username), do: Repo.insert!(create_user(username))
end