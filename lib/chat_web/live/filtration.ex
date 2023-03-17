defmodule ChatWeb.Filtration do
  @moduledoc """
  Provides logic for message filtration based on text and other parameters,
  the most common one being a toggle with various conditions
  """
  import ChatWeb.Storage

  @doc """
  filters out messages, primarily based on text, but also a line of toggle parameters
  that are described further in ever-growing checkbox_filter() function
  """
  def filter_messages(text, toggles),
    do:
      get_message_storage()
      |> filtrate_on_text(text)
      |> then(fn filtrated ->
        for {key, val} <- toggles, reduce: filtrated do
          acc -> checkbox_filter(acc, key, val)
        end
      end)

  @doc """
  checkbox_filter(messages, "action", "on") function filters out the given messages based on some logic
  the logic to use is recognized by the keyword string and "on" value
  any toggle that has "off" value skips the step of filtration, as it's needed to refresh filtration every time
  the search form is somehow changed
  """
  # returns messages that currently have likes, discarding the ones that do not
  def checkbox_filter(messages, "only-liked", "on"),
    do:
      Enum.filter(messages, fn message ->
        length(message.likes) > 0
      end)

  # returns messages based on the following criteria: message should contain at least one like
  # from a person that liked other messages apart from the one in question
  def checkbox_filter(messages, "liked-by-likers", "on"),
    do:
      Enum.filter(messages, fn message ->
        Enum.any?(message.likes, fn like ->
          others =
            for msg <- messages -- [message], reduce: [] do
              acc -> acc ++ Enum.map(msg.likes, fn l -> l.like_username end)
            end

          like.like_username in others
        end)
      end)

  # returns messages based on the following criteria: message should come from a user that didn't like any message, and it
  # shouldn't have any likes itself
  def checkbox_filter(messages, "not-liked-by-nonlikers", "on"),
    do:
      Enum.filter(messages, fn message ->
        message.likes == [] and
          Enum.all?(messages, fn msg ->
            message.author_username not in Enum.map(msg.likes, fn l -> l.like_username end)
          end)
      end)

  # returns messages based on the following criteria: the least amount of messages holding 80%+ of all likes
  # in the message timeline
  def checkbox_filter(messages, "20-percent-minority-most-liked", "on") do
    total_like_count_global = count_total_likes(messages)

    messages
    |> Enum.sort_by(&length(&1.likes), :desc)
    |> Enum.reduce_while([], fn message, acc ->
      if count_total_likes(acc) < total_like_count_global * 0.8,
        do: {:cont, [message | acc]},
        else: {:halt, acc}
    end)
  end

  # this is a sort of placeholder for all the toggles not yet implemented
  def checkbox_filter(messages, _not_implemented, "on"),
    do: messages

  # generalised case of when the toggle has an off value
  def checkbox_filter(messages, _key, "off"),
    do: messages

  # given a list of messages, counts the total number of likes that they have
  defp count_total_likes(messages),
    do: Enum.reduce(messages, 0, fn message, acc -> acc + length(message.likes) end)

  # given a text, searches for messages that contain it
  defp filtrate_on_text(messages, text) do
    case text do
      "" -> messages
      filter -> Enum.filter(messages, fn message -> message.message_text =~ filter end)
    end
  end
end
