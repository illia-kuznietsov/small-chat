defmodule Chat.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :username, :string
    end
  end
end
