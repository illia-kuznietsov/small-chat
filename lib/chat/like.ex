defmodule Chat.Like do
  use Ecto.Schema

  schema "likes" do
    field(:like_username, :string)
    many_to_many(:messages, Chat.Message, join_through: Chat.MessageLike, defaults: [])

    timestamps()
  end
end
