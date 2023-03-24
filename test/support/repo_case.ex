defmodule Chat.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Chat.Repo

      import Ecto
      import Ecto.Query
      import Chat.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Chat.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Chat.Repo, {:shared, self()})
    end

    :ok
  end
end
