defmodule ChatWeb.SmallTalkChannel do

  use ChatWeb, :channel

  @impl true
  def join("small_talk:lobby", _payload, socket) do
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (small_talk:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    Agent.update(MessageStorage, fn list -> [%{username: socket.assigns.username, message: payload["body"]} | list] end)
    broadcast(socket, "shout", %{"nickname" => socket.assigns.username, "message" => payload["body"]})
    {:noreply, socket}
  end

end
