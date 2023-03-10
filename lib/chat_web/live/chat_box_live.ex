defmodule ChatWeb.ChatBoxLive do
  use Phoenix.Component
  use Phoenix.HTML

  def chat_box(assigns) do
    ~H"""
      <div id="chat-box">
        <%= for message <- @messages do%>
          <p><%= message.username %>  :  <%= message.message %></p>
          <button phx-click="like" phx-value-id={message.id} title={message.likes}><%= length(message.likes) %></button>
        <% end %>
      </div>
    """
  end
end
