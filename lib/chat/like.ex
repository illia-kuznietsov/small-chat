defmodule Chat.Like do
  use Ecto.Schema
  alias Chat.{Message, User}

  schema "likes" do
    belongs_to(:message, Message)
    belongs_to(:user, User)
  end
end
