defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :author_username, :string, null: false
      add :message_text, :text
      add :time_stamp, :string, null: false
    end
  end
end
