defmodule Chat.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    many_to_many(:likes, Chat.Message, join_through: Chat.Like, defaults: [])

  end
  def changeset(struct, params) do
    struct
    |> cast(params, [:username])
    |> validate_required([:username])
  end
end
