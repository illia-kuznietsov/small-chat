defmodule ChatWeb.CreateMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def message_form(assigns) do
    ~H"""
      <form id="message_form" phx-submit="send">
        <input type="text" placeholder="Your message" name="message" />
        <button>Send</button>
      </form>
    """
  end
end
