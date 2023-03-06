defmodule ChatWeb.SearchMessageFormLive do
  use Phoenix.Component
  use Phoenix.HTML

  def search_form(assigns) do
    ~H"""
      <form phx-change="filter">
        <input type="text" placeholder="search message here..." name="filter-text" value={@filter}/>
        <input type="checkbox" name="toggle" checked={@checked}/>
      </form>
    """
  end
end