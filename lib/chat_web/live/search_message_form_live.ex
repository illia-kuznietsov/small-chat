defmodule ChatWeb.SearchMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def search_form(assigns) do
    ~H"""
      <h1>Search Filters</h1>
      <form id="search_form" phx-change="filter" class="search">
        <input type="text" placeholder="search message here..." name="filter-text" value={@filter}/>
        <div class="checkboxes">
          <div><%= Phoenix.HTML.Form.checkbox(:like_filter, "only-liked", checked_value: "on", unchecked_value: "off") %><a title="show only liked messages"> (?)</a></div>
          <div><%= Phoenix.HTML.Form.checkbox(:like_filter, "liked-by-likers", checked_value: "on", unchecked_value: "off") %><a title="show messages with likes from users that liked multiple"> (?)</a></div>
          <div><%= Phoenix.HTML.Form.checkbox(:like_filter, "not-liked-by-nonlikers", checked_value: "on", unchecked_value: "off") %><a title="show messages with 0 likes from users that didn't like any"> (?)</a></div>
          <div><%= Phoenix.HTML.Form.checkbox(:like_filter, "20-percent-minority-most-liked", checked_value: "on", unchecked_value: "off") %><a title="show the least of messages that have 80%+ of total likes"> (?)</a></div>
        </div>
      </form>
    """
  end
end
