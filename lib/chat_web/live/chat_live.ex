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
    Phoenix.PubSub.subscribe(Chat.PubSub,"chat")
    socket = assign(socket, username: generate_username())
    socket = assign(socket, messages: get_message_storage())
    socket = assign(socket, checked: false)
    socket = assign(socket, text: "")
    {:ok, socket}
  end
  defp get_message_storage(), do: Agent.get(MessageStorage, fn list -> list |> Enum.reverse end)
  defp broadcast_updated_messages(), do: Phoenix.PubSub.broadcast(Chat.PubSub, "chat", {:chat_update, "whatever"})
  def render(assigns) do
    filtered = assigns.messages
    case assigns.text do
      "" -> filtered = get_message_storage()
      filter -> filtered = Enum.filter(filtered, fn message -> message.message =~ filter end)
    end
    if assigns.checked do
      filtered = Enum.filter(filtered, fn message -> length(message.likes) > 0 end)
    end
    ~H"""
      <section class="phx-hero">
        <h1><%= gettext "Welcome to the Chat, %{name}!", name: @username %></h1>
      </section>

      <div id="chat-box">
        <%= for message <- filtered do%>
          <p><%= message.username %>  :  <%= message.message %></p>
          <button phx-click="like" phx-value-id={message.id} title={Enum.join(message.likes, ", ")}><%= length(message.likes) %></button>
        <% end %>
      </div>

    <form phx-submit="send">
      <input type="text" placeholder="Your message" name="message" />
      <button>Send</button>
    </form>
    <form phx-change="filter">
      <input type="text" placeholder="search message here..." name="filter-message" />
    </form>
    <input type="checkbox" phx-click="toggle" checked={@checked}/>
    """
  end


  def handle_event("send", params, socket) do
    time_stamp = get_time()
    username = socket.assigns.username
    message = params["message"]
    id = generate_id(username, message, time_stamp)
    Agent.update(MessageStorage, fn list ->
      [%{username: username, message: message, likes: [], time_stamp: time_stamp, id: id} | list] end)
    broadcast_updated_messages()
    {:noreply, socket}
  end


  def handle_event("like", params, socket) do
    Agent.update(MessageStorage, fn list -> find_and_update_likes(list, params["id"], socket.assigns.username) end)

    broadcast_updated_messages()
    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    {:noreply, assign(socket, text: params["filter-message"])}
  end

  def handle_event("toggle", _params, socket) do
    {:noreply, assign(socket, checked: !socket.assigns.checked)}
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

  def handle_info({:chat_update, _}, socket) do
    socket = assign(socket, :messages, get_message_storage())
    {:noreply, socket}
  end
end