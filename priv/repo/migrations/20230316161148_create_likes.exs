defmodule Chat.Repo.Migrations.CreateMessageLike do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
    create unique_index(:likes, [:message_id, :user_id])
  end
end
