defmodule ChatWeb.Filtration do
  @moduledoc """
  Provides logic for message filtration based on text and other parameters,
  the most common one being a toggle with various conditions
  """
  import ChatWeb.Storage
  import Ecto.Query
  alias Chat.{Repo, Message, Like, User}

  @doc """
  filters out messages, primarily based on text, but also a line of toggle parameters
  that are described further in ever-growing checkbox_filter() function
  """
  def filter_messages(text, toggles),
    do:
      text
      |> filtrate_on_text()
      |> then(fn query ->
        for {key, val} <- toggles, reduce: query do
          acc -> checkbox_filter(acc, key, val)
        end
      end)
      |> Repo.all()
      |> Repo.preload([:likes])

  @doc """
  checkbox_filter(messages, "action", "on") function filters out the given messages based on some logic
  the logic to use is recognized by the keyword string and "on" value
  any toggle that has "off" value skips the step of filtration, as it's needed to refresh filtration every time
  the search form is somehow changed
  """
  # returns messages that currently have likes, discarding the ones that do not
  def checkbox_filter(query, "only-liked", "on") do
    ml_query =
      "SELECT l.message_id FROM likes AS l GROUP BY l.message_id HAVING count(l.user_id) > 0;"

    ids = Repo.query!(ml_query).rows |> List.flatten()
    from(m in query, where: m.id in ^ids)
  end

  # returns messages based on the following criteria: message should contain at least one like
  # from a person that liked other messages apart from the one in question
  def checkbox_filter(query, "liked-by-likers", "on") do
    ml_query = "SELECT message_id FROM likes WHERE user_id IN(SELECT user_id FROM likes GROUP BY user_id HAVING COUNT(*) > 1);"

    ids = Repo.query!(ml_query).rows |> List.flatten() |> Enum.uniq()
    from(m in query, where: m.id in ^ids)
  end

  # returns messages based on the following criteria: message should come from a user that didn't like any message, and it
  # shouldn't have any likes itself
  def checkbox_filter(query, "not-liked-by-nonlikers", "on") do
    l_query =
      "SELECT l.message_id FROM likes AS l GROUP BY l.message_id HAVING count(l.user_id) > 0;"
    l_ids = Repo.query!(l_query).rows |> List.flatten()
    m_query =
      "SELECT user_id FROM likes GROUP BY user_id HAVING COUNT(*) > 0;"
    m_ids = Repo.query!(m_query).rows |> List.flatten() |> Enum.uniq()
    IO.inspect(m_ids)
    query_1 = from(m in query, where: m.id not in ^l_ids)
    from(m in query_1, where: m.author_id not in ^m_ids)
  end

  # returns messages based on the following criteria: the least amount of messages holding 80%+ of all likes
  # in the message timeline
  def checkbox_filter(query, "20-percent-minority-most-liked", "on") do
    ml_query = "SELECT top (20) percent l.message_id from likes as l ORDER BY COUNT(l.user_id);"
    ids = Repo.query!(ml_query).rows |> List.flatten()
    from(m in query, where: m.id in ^ids)
  end

  # this is a sort of placeholder for all the toggles not yet implemented
  def checkbox_filter(query, _not_implemented, "on"),
    do: query

  # generalised case of when the toggle has an off value
  def checkbox_filter(query, _key, "off"),
    do: query

  # given a text, searches for messages that contain it
  defp filtrate_on_text(text) do
    filter = "%#{text}%"

    case text do
      "" -> from(m in Chat.Message)
      _ -> from(m in Chat.Message, where: like(m.text_body, ^filter))
    end
  end
end
