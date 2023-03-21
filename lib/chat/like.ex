defmodule Chat.Like do
  use Ecto.Schema

  schema "likes" do
    belongs_to(:message, Chat.Message)
    belongs_to(:user, Chat.User)
  end
end
