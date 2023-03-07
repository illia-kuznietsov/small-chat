defmodule ChatWeb.SearchMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def search_form(assigns) do
    ~H"""
      <form id="search_form" phx-change="filter">
        <input type="text" placeholder="search message here..." name="filter-text" value={@filter}/>
        <%= Phoenix.HTML.Form.checkbox(:like_filter, "toggle", checked_value: "on", unchecked_value: "off", value: @checked) %>

      </form>
    """
  end
end
