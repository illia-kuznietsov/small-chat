defmodule ChatWeb.ChatLiveTest do
  import Phoenix.LiveViewTest
  use ChatWeb.ConnCase

  test "connected mount", %{conn: conn} do
    conn = get(conn, "/chat")
    {:ok, _view, html} = conn |> live
    assert html =~ "<form phx-submit=\"send\"><input type=\"text\" placeholder=\"Your message\" name=\"message\"/><button>Send</button></form>"
  end

  test "another mount test", %{conn: conn} do
    conn = get(conn, "/chat")
    assert html_response(conn, 200) =~ "<h1>Welcome to the Chat, #{conn.assigns.username}!</h1>"
  end

  test "renders ok" do
    assigns = %{username: "test", messages: [], filter: "", checked: false}
    assert render_component(&ChatWeb.ChatLive.render/1, assigns) =~ "<h1>Welcome to the Chat, test!</h1>"
  end

#   test "handle_events" do
#    socket.assigns = %{username: "test", messages: [], filter: "", checked: false}
#    {:noreply, socket} = ChatWeb.ChatLive.handle_event("send", %{"message" => "blah"} , socket)
#    assert Enum.any?(socket.assigns.messages, fn message -> message.message == "blah" end)
#  end


end