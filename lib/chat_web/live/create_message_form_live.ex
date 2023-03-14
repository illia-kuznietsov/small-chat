defmodule ChatWeb.CreateMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def message_form(assigns) do
    ~H"""
      <form id="message_form" phx-submit="send" class="post-msg">
        <input type="text" placeholder="Your message" name="message" />
        <button>&#x21E8 send &#x21E6</button>
      </form>
    """
  end
end
