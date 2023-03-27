defmodule Chat.Repo.Migrations.CreateMessagesAndUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
    end

    create table(:messages) do
      add :author_id, references(:users, on_delete: :delete_all)
      add :author_username, :string, null: false
      add :text_body, :text

      timestamps()
    end
  end
end
