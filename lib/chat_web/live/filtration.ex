defmodule ChatWeb.Filtration do
  import ChatWeb.Storage

  def filter_messages(text, toggles),
    do:
      filtrate_on_text(text)
      |> then(fn filtrated ->
          Enum.reduce(toggles, filtrated, fn {key, value}, acc ->
            acc = checkbox_filter(acc, key, value)
          end)
      end)

  def checkbox_filter(messages, "only-liked", "on"),
    do:
      Enum.filter(messages, fn message ->
        length(message.likes) > 0
      end)

  def checkbox_filter(messages, "liked-by-likers", "on"),
    do:
      Enum.filter(messages, fn message ->
        Enum.any?(message.likes, fn username ->
          username in Enum.reduce(messages -- [message], [], fn msg, acc -> msg.likes ++ acc end)
        end)
      end)

  def checkbox_filter(messages, "not-liked-by-nonlikers", "on"),
    do:
      Enum.filter(messages, fn message ->
        message.likes == [] and
          Enum.all?(messages, fn msg ->
            message.username not in msg.likes
          end)
      end)

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

  def checkbox_filter(messages, _key, "off"),
    do: messages

  defp count_total_likes(messages),
    do: Enum.reduce(messages, 0, fn message, acc -> acc + length(message.likes) end)

  defp filtrate_on_text(text) do
    case text do
      "" -> get_message_storage()
      filter -> Enum.filter(get_message_storage(), fn message -> message.message =~ filter end)
    end
  end
end
