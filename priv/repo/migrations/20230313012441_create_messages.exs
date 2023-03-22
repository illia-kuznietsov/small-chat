defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :author, references(:users, on_delete: :delete_all)
      add :author_username, :string, null: false
      add :text_body, :text

      timestamps()
    end
  end
end
