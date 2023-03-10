defmodule ChatWeb.SearchMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def search_form(assigns) do
    ~H"""
      <form id="search_form" phx-change="filter">
        <input type="text" placeholder="search message here..." name="filter-text" value={@filter}/>
        <%= Phoenix.HTML.Form.checkbox(:like_filter, "only-liked", checked_value: "on", unchecked_value: "off") %>
        <%= Phoenix.HTML.Form.checkbox(:like_filter, "liked-by-likers", checked_value: "on", unchecked_value: "off") %>
        <%= Phoenix.HTML.Form.checkbox(:like_filter, "not-liked-by-nonlikers", checked_value: "on", unchecked_value: "off") %>
        <%= Phoenix.HTML.Form.checkbox(:like_filter, "20-percent-minority-most-liked", checked_value: "on", unchecked_value: "off") %>
      </form>
    """
  end
end
