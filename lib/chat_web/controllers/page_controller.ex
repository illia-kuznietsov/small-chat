defmodule ChatWeb.PageController do
  use ChatWeb, :controller



  def index(conn, _params) do
    render(conn, "index.html", messages: Agent.get(MessageStorage, fn list -> list |> Enum.reverse end))
  end
end
