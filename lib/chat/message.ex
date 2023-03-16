defmodule Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :message_text, :string
    field :author_username, :string
    field :time_stamp, :string
    has_many :likes, Chat.Like
  end
  def changeset(struct, params) do
    struct
    |> cast(params, [:message_text, :author_username, :time_stamp])
    |> validate_required([:author_username, :time_stamp])
  end
end