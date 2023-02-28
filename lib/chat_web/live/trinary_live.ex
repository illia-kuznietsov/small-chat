defmodule ChatWeb.TrinaryLive do
  use ChatWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, n: 4)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1> Welcome to the page! Current n is <%= @n %> </h1>
    <form phx-submit="change_n">
      <input type="text" placeholder={"#{@n}"} name="n" />
      <button>Change n</button>
    </form>
    <%=
      Enum.map(0..((:math.pow(3,@n) - 1) |> round()), fn number -> Integer.digits(number, 3) end)

      |> Enum.join(", ")
    %>
    """
  end

  def handle_event("change_n", params, socket) do
    IO.inspect(socket)
    {:noreply, assign(socket, n: params["n"])}
  end

end