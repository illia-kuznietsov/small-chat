defmodule ChatWeb.ChatLiveTest do
  import Phoenix.LiveViewTest
  use ChatWeb.ConnCase

  test "connected mount", %{conn: conn} do
    conn = get(conn, "/chat")
    {:ok, _view, html} = conn |> live
    assert html =~ "<div id=\"chat-box\">"
  end
end