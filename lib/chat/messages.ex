defmodule Chat.Messages do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "messages" do
    field :message_text, :string
    field :username, :string
    field :time_stamp, :string
    has_many :likes, Chat.Likes
  end
end