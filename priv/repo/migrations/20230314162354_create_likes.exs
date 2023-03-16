defmodule Chat.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :like_username, :string, null: false
      timestamps()
    end
  end
end
