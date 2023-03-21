defmodule ChatWeb.Filtration do
  @moduledoc """
  Provides logic for message filtration based on text and other parameters,
  the most common one being a toggle with various conditions
  """
  import ChatWeb.Storage
  import Ecto.Query
  alias Chat.Repo

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
      "SELECT ml.message_id FROM message_like AS ml GROUP BY ml.message_id HAVING count(ml.like_id) > 0;"

    ids = Repo.query!(ml_query).rows |> List.flatten()
    from(m in query, where: m.id in ^ids)
  end

  # returns messages based on the following criteria: message should contain at least one like
  # from a person that liked other messages apart from the one in question
    def checkbox_filter(query, "liked-by-likers", "on") do
      ml_query = "SELECT * FROM message_like WHERE message_id = 1 or message_id = 2"
#      ml_query = "SELECT message_id FROM message_like WHERE like_id IN(SELECT like_id FROM message_like GROUP BY like_id HAVING COUNT(like_id) > 1);"
      ids = Repo.query!(ml_query).rows |> IO.inspect(label: "query result")
      from m in query, where: m.id in (^ids)
    end

    # returns messages based on the following criteria: message should come from a user that didn't like any message, and it
    # shouldn't have any likes itself
    def checkbox_filter(query, "not-liked-by-nonlikers", "on") do
      ml_query = "SELECT ml.message_id FROM (SELECT ml from message_like as ml GROUP BY ml.like_id HAVING COUNT(ml.message_id) > 0"
      ids = Repo.query!(ml_query).rows |> List.flatten()
      from m in query, where: m.id not in (^ids)
    end

    # returns messages based on the following criteria: the least amount of messages holding 80%+ of all likes
    # in the message timeline
    def checkbox_filter(query, "20-percent-minority-most-liked", "on") do
      ml_query = "SELECT top (20) percent ml.id from message_like as ml order by count(ml.like_id)"
      ids = Repo.query!(ml_query).rows |> List.flatten()
      from m in query, where: m.id in (^ids)
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
      _ -> from(m in Chat.Message, where: like(m.message_text, ^filter))
    end
  end
end
