defmodule Chat.MessageLike do
  use Ecto.Schema

  schema "message_like" do
    belongs_to(:message, Chat.Message)
    belongs_to(:like, Chat.Like)

    timestamps()
  end
end
