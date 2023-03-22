defmodule Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.{Like, User}

  schema "messages" do
    field(:text_body, :string)
    field(:author_username, :string)
    belongs_to(:author, User)
    many_to_many(:likes, User, join_through: Like, defaults: [])

    timestamps()
  end

end
