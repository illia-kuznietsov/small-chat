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
    ml_query =  "SELECT ml.message_id, count(ml.like_id) FROM message_like as ml GROUP BY ml.message_id WHERE count(ml.like_id) > 0"
    from m in query, where: m.id in (^ml_query)
  end

  # returns messages based on the following criteria: message should contain at least one like
  # from a person that liked other messages apart from the one in question
  def checkbox_filter(query, "liked-by-likers", "on") do
    ml_query = "SELECT ml.message_id, count(ml.message_id) FROM message_like as ml GROUP BY ml.like_id WHERE count(ml.message_id) > 1"
    from m in query, where: m.id in (^ml_query)
  end

  # returns messages based on the following criteria: message should come from a user that didn't like any message, and it
  # shouldn't have any likes itself
  def checkbox_filter(query, "not-liked-by-nonlikers", "on") do
    ml_query = "SELECT ml.message_id, count(ml.like_id) FROM message_like as ml GROUP BY ml.message_id WHERE count(ml.like_id) = 0"
    from m in query, where: m.id in (^ml_query)
  end
#    do:
#      from(m in query,
#        where:
#          m.likes == [] and
#            m.author_username not in Repo.all(query)
#            |> Repo.preload([:likes])
#            |> Enum.map(fn m -> m.likes end)
#            |> List.flatten()
#      )

  #      Enum.filter(messages, fn message ->
  #        message.likes == [] and
  #          Enum.all?(messages, fn msg ->
  #            message.author_username not in Enum.map(msg.likes, fn l -> l.like_username end)
  #          end)
  #      end)

  # returns messages based on the following criteria: the least amount of messages holding 80%+ of all likes
  # in the message timeline
#  def checkbox_filter(query, "20-percent-minority-most-liked", "on") do
#    total_like_count_global = count_total_likes(get_message_storage())
#
#    from(m in query,
#      where:
#        (m in Repo.all(query))
#        |> Repo.preload([:likes])
#        |> Enum.sort_by(&length(&1.likes), :desc)
#        |> Enum.reduce_while([], fn message, acc ->
#          if count_total_likes(acc) < total_like_count_global * 0.8,
#            do: {:cont, [message | acc]},
#            else: {:halt, acc}
#        end)
#    )

    #    messages
    #    |> Enum.sort_by(&length(&1.likes), :desc)
    #    |> Enum.reduce_while([], fn message, acc ->
    #      if count_total_likes(acc) < total_like_count_global * 0.8,
    #        do: {:cont, [message | acc]},
    #        else: {:halt, acc}
    #    end)
#  end

  # this is a sort of placeholder for all the toggles not yet implemented
  def checkbox_filter(query, _not_implemented, "on"),
    do: query

  # generalised case of when the toggle has an off value
  def checkbox_filter(query, _key, "off"),
    do: query

  # given a list of messages, counts the total number of likes that they have
  defp count_total_likes(messages),
    do: Enum.reduce(messages, 0, fn message, acc -> acc + length(message.likes) end)

  # given a text, searches for messages that contain it
  defp filtrate_on_text(text) do
    filter = "%#{text}%"
    case text do
      "" -> from(m in Chat.Message)
      _ -> from(m in Chat.Message, where: like(m.message_text, ^filter))
    end
  end
end
