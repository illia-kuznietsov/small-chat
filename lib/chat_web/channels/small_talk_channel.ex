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
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

end
