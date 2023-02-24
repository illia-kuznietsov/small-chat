defmodule ChatWeb.SmallTalkChannel do

  use ChatWeb, :channel

  @impl true
  def join("small_talk:lobby", _payload, socket) do
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (small_talk:lobby).
  def generate_id(username, message, time_stamp) do
    Base.encode16(:erlang.md5(username <> time_stamp <> String.slice(message, 0..32)))
  end

  def get_time() do
    d = DateTime.utc_now()
    "#{d.year}/#{d.month}/#{d.day}-#{d.hour}:#{d.minute}:#{d.second}"
  end
  @impl true
  def handle_in("shout", payload, socket) do
    time_stamp = get_time()
    username = socket.assigns.username
    message = payload["body"]
    id = generate_id(username, message, time_stamp)
    Agent.update(MessageStorage, fn list -> [%{username: username, message: message, likes: [],
      time_stamp: time_stamp, id: id} | list] end)
    broadcast(socket, "shout", %{"nickname" => username, "message" => message})
    {:noreply, socket}
  end
  def find_and_update_likes(list, id, username) do
    update_in(list, [Access.filter(&match?(%{id: id}, &1))], &Map.merge(&1, &1, fn :likes, v, _ ->
      if Enum.member?(v, username) do
        v -- [username]
      else
        [username | v]
      end
    end))
  end
  @impl true
  def handle_in("like", payload, socket) do
    Agent.update(MessageStorage, fn list -> find_and_update_likes(list, payload["id"], socket.assigns.username) end)
    broadcast(socket, "like", %{"id" => payload["id"], "likes" => ["hello", "world"]})
    {:noreply, socket}
  end

end
