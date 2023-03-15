defmodule Chat.Likes do
  use Ecto.Schema

  schema "likes" do
    field :username, :string
    belongs_to(:message, Chat.Messages)
  end
end