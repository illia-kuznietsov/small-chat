defmodule Chat.Like do
  use Ecto.Schema

  schema "likes" do
    field :like_username, :string
    belongs_to :message, Chat.Message
  end

end