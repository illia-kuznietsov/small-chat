defmodule ChatWeb.Filtration do
  import ChatWeb.Storage

  def filter_messages(text, only_liked_toggle, liker_toggle, not_liked_toggle, minority_toggle),
    do:
      filtrate_on_text(text)
      |> only_liked_filter(only_liked_toggle)
      |> liker_filter(liker_toggle)
      |> not_liked_filter(not_liked_toggle)
      |> minority_filter(minority_toggle)

  def only_liked_filter(messages, "on"),
    do:
      Enum.filter(messages, fn message ->
        length(message.likes) > 0
      end)

  def only_liked_filter(messages, "off"),
    do: messages

  def liker_filter(messages, "on"),
    do:
      Enum.filter(messages, fn message ->
        Enum.any?(message.likes, fn username ->
          username in Enum.reduce(messages -- [message], [], fn msg, acc -> msg.likes ++ acc end)
        end)
      end)

  def liker_filter(messages, "off"),
    do: messages

  def not_liked_filter(messages, "on"),
    do:
      Enum.filter(messages, fn message ->
        message.likes == [] and
          Enum.all?(messages, fn msg ->
            message.username not in msg.likes
          end)
      end)

  def not_liked_filter(messages, "off"),
    do: messages

  def minority_filter(messages, "on") do
    total_like_count_global = count_total_likes(messages)
    messages
    |> Enum.sort_by(&length(&1.likes), :desc)
    |> Enum.reduce_while([], fn message, acc ->
      if length(message.likes) + count_total_likes(acc) < total_like_count_global * 0.8,
        do: {:cont, [message | acc]},
        else: {:halt, acc}
    end)
  end

  def minority_filter(messages, "off"),
    do: messages

  def count_total_likes(messages),
    do: Enum.reduce(messages, 0, fn message, acc -> acc + length(message.likes) end)

  defp filtrate_on_text(text) do
    case text do
      "" -> get_message_storage()
      filter -> Enum.filter(get_message_storage(), fn message -> message.message =~ filter end)
    end
  end
end
