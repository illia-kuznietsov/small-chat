defmodule ChatWeb.ChatBoxLive do
  use Phoenix.Component
  use Phoenix.HTML

  def chat_box(assigns) do
    ~H"""
        <%= for message <- @messages do%>
          <div class="message">
            <button phx-click="like" phx-value-id={message.id} title={format_likes(message.likes)}>&#x2764; <%= length(message.likes) %></button>
            <p><%= message.author_username %>  :  <%= message.text_body %></p>
          </div>
        <% end %>

    """
  end

  def format_likes(likes) do
    likes |> Enum.map(fn like -> like.username end) |> Enum.join(", ")
  end
end
