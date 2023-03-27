defmodule Chat.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.{Message, Like}

  schema "users" do
    field(:username, :string)
    many_to_many(:likes, Message, join_through: Like, defaults: [])
    has_many(:messages, Message, defaults: [])
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:username])
    |> validate_required([:username])
  end
end
