defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  use Phoenix.Component
  import ChatWeb.{Username, Storage, Filtration}
  alias Chat.{Repo, Message}

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Chat.PubSub, "chat")
    username = generate_username()
    user_id = save_user(username).id
    socket = assign(socket, username: username)
    socket = assign(socket, user_id: user_id)
    socket = assign(socket, profile: "default.jpg")
    socket = assign(socket, mini: "default.png")
    socket = assign(socket, messages: filter_messages("", []))
    socket = assign(socket, filter: "")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <style>
        .grid{
          display:grid;
          grid-template-columns:3fr 1fr;
          grid-gap:1em;
        }
        .grid > div {
          background:#ddd;
          padding:1em;
        }
        .grid > div:nth-child(odd){
          background:#eee;
        }
        .profile {
          height:15em;
        }
        .profile > img{
          border-radius:50%;
        }
        .profile > img:nth-child(2){
          transform:scale(0.5) translate(100%, -250%);
        }
        .chatbox{
          display:flex;
          flex-direction: column;
          overflow:auto;
          overflow-anchor:initial;
          height: 30em;
        }
        .message{
          display:flex;
          flex-direction:row;
          gap:1em;
        }
        .sidebar{
          display:flex;
          flex-direction:column;
          gap:1em;
        }
        .post-msg{
          display:flex;
          flex-direction:column;
        }
        .search{
          display:flex;
          flex-direction:column;
          gap:1em;
        }
        .checkboxes{
          display:flex;
          flex-direction:column;
          gap:0.5em;
        }
      </style>
      <div class="grid">
        <div id="chat-box" class="chatbox">
          <ChatWeb.ChatBoxLive.chat_box messages={@messages} />
        </div>
        <div class="sidebar">
          <div>
            <div class="profile">
              <img src={~p"/profile_pics/#{@profile}"} />
              <img src={~p"/mini_pics/#{@mini}"} />
            </div>
              <section class="phx-hero">
                <h1><%= gettext "Welcome to the Chat, \n %{name}!", name: @username %></h1>
              </section>
            <ChatWeb.CreateMessageFormLive.message_form />
          </div>
          <div>
            <ChatWeb.SearchMessageFormLive.search_form filter={@filter} />
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    post_message(message, socket.assigns.user_id, socket.assigns.username)
    broadcast_updated_messages()
    {:noreply, socket}
  end

  @impl true
  def handle_event("like", %{"id" => message_id}, socket) do
    update_message_likes(message_id, socket.assigns.user_id)
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
    socket = assign(socket, :messages, Repo.all(Message) |> Repo.preload([:likes]))
    {:noreply, socket}
  end

  defp broadcast_updated_messages(),
    do: Phoenix.PubSub.broadcast(Chat.PubSub, "chat", {:chat_update, "whatever"})
end
