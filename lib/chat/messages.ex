defmodule Chat.Message do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "messages" do
    field :message_text, :string
    field :username, :string
    field :time_stamp, :string
    field :likes, {:array, string}
  end
end