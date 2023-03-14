defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message_text, :string
      add :username, :string
      add :time_stamp, :string
      add :likes, {:array, :string}
    end
  end
end
