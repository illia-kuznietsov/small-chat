defmodule Chat.Repo.Migrations.CreateMessageLike do
  use Ecto.Migration

  def change do
    create table(:message_like) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :like_id, references(:likes, on_delete: :delete_all)

      timestamps()
    end
  end
end
