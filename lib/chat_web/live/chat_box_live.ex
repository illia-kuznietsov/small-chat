defmodule ChatWeb.ChatBoxLive do
  use Phoenix.Component
  use Phoenix.HTML

  def chat_box(assigns) do
    ~H"""
        <%= for message <- @messages do%>
          <div class="message">
            <button phx-click="like" phx-value-id={message.id} title={message.likes}>&#x2764; <%= length(message.likes) %></button>
            <p><%= message.username %>  :  <%= message.message %></p>
          </div>
        <% end %>

    """
  end
end
