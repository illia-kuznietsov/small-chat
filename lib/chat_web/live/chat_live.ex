defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  use Phoenix.Component
  import ChatWeb.Username
  import ChatWeb.Storage

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Chat.PubSub,"chat")
    socket = assign(socket, username: generate_username())
    socket = assign(socket, messages: get_message_storage())
    socket = assign(socket, checked: false)
    socket = assign(socket, filter: "")
    {:ok, socket}
  end

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
    <form phx-change="filter">
      <input type="text" placeholder="search message here..." name="filter-text" value={@filter}/>
      <input type="checkbox" name="toggle" checked={@checked}/>
    </form>
    """
  end

  def handle_event("send", params, socket) do
    time_stamp = Calendar.strftime(DateTime.utc_now(), "%A %d-%m-%Y %H:%M:%S")
    username = socket.assigns.username
    message = params["message"]
    id = UUID.uuid4()
    post_message(username, message, time_stamp, id)
    broadcast_updated_messages()
    {:noreply, socket}
  end

  def handle_event("like", params, socket) do
    update_message_likes(params, socket.assigns.username)
    broadcast_updated_messages()
    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    case params["toggle"] do
      "on" -> {:noreply, assign(socket, filter: params["filter-text"], checked: true,
        messages: Enum.filter(filtrate_on_text(params["filter-text"]), fn message -> length(message.likes) > 0 end))}
      nil -> {:noreply, assign(socket, filter: params["filter-text"], checked: false, messages: filtrate_on_text(params["filter-text"]))}
    end
  end

  def handle_info({:chat_update, _}, socket) do
    socket = assign(socket, :messages, get_message_storage())
    {:noreply, socket}
  end

  defp filtrate_on_text(text) do
    case text do
      "" -> get_message_storage()
      filter -> Enum.filter(get_message_storage(), fn message -> message.message =~ filter end)
    end
  end

  defp broadcast_updated_messages(), do: Phoenix.PubSub.broadcast(Chat.PubSub, "chat", {:chat_update, "whatever"})

end