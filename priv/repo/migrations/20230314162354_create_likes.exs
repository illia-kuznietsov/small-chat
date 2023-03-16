defmodule Chat.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :like_username, :string, null: false
      add :message_id, references(:messages)
      timestamps()
    end
  end
end
