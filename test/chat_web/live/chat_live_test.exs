defmodule ChatWeb.ChatLiveTest do
  import Phoenix.LiveViewTest
  use ChatWeb.ConnCase

  test "connected mount", %{conn: conn} do
    conn = get(conn, "/chat")
    {:ok, _view, html} = conn |> live

    assert html =~
             "<form id=\"message_form\" phx-submit=\"send\" class=\"post-msg\"><input type=\"text\" placeholder=\"Your message\" name=\"message\"/><button>&amp;#x21E8 send &amp;#x21E6</button></form>"
  end

  test "another mount test", %{conn: conn} do
    conn = get(conn, "/chat")

    assert html_response(conn, 200) =~
             "<h1>Welcome to the Chat, \n #{conn.assigns.username}!</h1>"
  end

  test "renders ok" do
    assigns = %{username: "test", messages: [], filter: "", checked: false, profile: "", mini: ""}

    assert render_component(&ChatWeb.ChatLive.render/1, assigns) =~
             "<h1>Welcome to the Chat, \n test!</h1>"
  end

  test "chat box" do
    assigns = [%{username: "test", message: "test", likes: [], id: "aaa"}]

    assert render_component(&ChatWeb.ChatBoxLive.chat_box/1, messages: assigns) =~
             "<p>test  :  test</p>"
  end
end
