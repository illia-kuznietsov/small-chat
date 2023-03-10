defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  use Phoenix.Component
  import ChatWeb.Username
  import ChatWeb.Message
  import ChatWeb.Storage
  import ChatWeb.Filtration

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Chat.PubSub, "chat")
    socket = assign(socket, username: generate_username())
    socket = assign(socket, messages: get_message_storage())
    socket = assign(socket, filter: "")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <section class="phx-hero">
        <h1><%= gettext "Welcome to the Chat, %{name}!", name: @username %></h1>
      </section>
      <ChatWeb.ChatBoxLive.chat_box messages={@messages} />
      <ChatWeb.CreateMessageFormLive.message_form />
      <ChatWeb.SearchMessageFormLive.search_form filter={@filter} />
    """
  end

  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    create_message(socket.assigns.username, message) |> post_message()
    broadcast_updated_messages()
    {:noreply, socket}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    update_message_likes(id, socket.assigns.username)
    broadcast_updated_messages()
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "filter",
        %{
          "filter-text" => text,
          "like_filter" => toggles
        },
        socket
      ) do
    socket
    |> assign(
      filter: text,
      messages: filter_messages(text, toggles)
    )
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:chat_update, _}, socket) do
    socket = assign(socket, :messages, get_message_storage())
    {:noreply, socket}
  end

  defp broadcast_updated_messages(),
    do: Phoenix.PubSub.broadcast(Chat.PubSub, "chat", {:chat_update, "whatever"})
end
