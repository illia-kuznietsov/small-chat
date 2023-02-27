defmodule ChatWeb.LightLive do
  use ChatWeb, :live_view

  #mount
  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  #render
  def render(assigns) do
    ~H"""
      <h1>Front Porch Live</h1>
      <div id="light">
        <div class="meter">
          <span style={"width=#{@brightness}%"}%>
            <%= @brightness %>%
          </span>
        </div>
        <button phx-click="on">on</button>
        <button phx-click="down">down</button>
        <button phx-click="up">up</button>
        <button phx-click="off">off</button>
      </div>
    """
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    socket = update(socket, :brightness, &(&1+10))
    {:noreply, socket}
  end

  def handle_event("down", _payload, socket) do
    socket = update(socket, :brightness, &(&1-10))
    {:noreply, socket}
  end

end