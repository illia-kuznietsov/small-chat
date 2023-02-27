defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  use Phoenix.Component

  defp load_pick_random(path) do
    File.stream!(Application.app_dir(:chat, path)) |> Enum.map(&String.trim/1) |> Enum.random()
  end
  defp generate_username() do
    adjectives_and_animals = ["/priv/static/username_generation/adjectives.txt",
      "/priv/static/username_generation/animals.txt"]
    [adjective, animal] = Enum.map(adjectives_and_animals, &load_pick_random/1)
    "#{adjective} #{animal}"
  end
  def mount(_params, _session, socket) do
    socket = assign(socket, username: generate_username())
    socket = assign(socket, messages: get_message_storage)
    IO.inspect(socket)
    {:ok, socket}
  end
  defp get_message_storage(), do: Agent.get(MessageStorage, fn list -> list |> Enum.reverse end)

  def render(assigns) do
    ~H"""
      <section class="phx-hero">
        <h1><%= gettext "Welcome to the Chat, %{name}!", name: @username %></h1>
      </section>

      <div id="chat-box">
        <%= for message <- @messages do%>
            <p><%= message.username %>  :  <%= message.message %></p>
            <button phx-click="like" phx-value-id={message.id} title={message.likes}><%= length(message.likes) %></button>
        <% end %>
      </div>

    <form phx-submit="send">
      <input type="text" placeholder="Your message" name="message" />
      <button>Send</button>
    </form>
    """
  end


  def handle_event("send", params, socket) do
    time_stamp = get_time()
    username = socket.assigns.username
    message = params["message"]
    id = generate_id(username, message, time_stamp)
    Agent.update(MessageStorage, fn list ->
      [%{username: username, message: message, likes: [], time_stamp: time_stamp, id: id} | list] end)
    socket = assign(socket, :messages, get_message_storage)
    {:noreply, socket}
  end

  def handle_event("like", params, socket) do
    IO.inspect(socket.assigns.messages)
    Agent.update(MessageStorage, fn list -> find_and_update_likes(list, params["id"], socket.assigns.username) end)
    socket = assign(socket, :messages, get_message_storage)
    {:noreply, socket}
  end

  defp generate_id(username, message, time_stamp) do
    Base.encode16(:erlang.md5(username <> time_stamp <> String.slice(message, 0..32)))
  end

  defp get_time() do
    d = DateTime.utc_now()
    "#{d.year}/#{d.month}/#{d.day}-#{d.hour}:#{d.minute}:#{d.second}"
  end

  defp find_and_update_likes(list, id, username) do
    update_in(list, [Access.filter(&match?(%{id: ^id}, &1))], &Map.replace_lazy(&1, :likes, fn v ->
      if Enum.member?(v, username) do
        v -- [username]
      else
        [username | v]
      end
    end))
  end
end