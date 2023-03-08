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
    do: messages

  def not_liked_filter(messages, "off"),
    do: messages

  def minority_filter(messages, "on"),
    do: messages

  def minority_filter(messages, "off"),
    do: messages

  defp filtrate_on_text(text) do
    case text do
      "" -> get_message_storage()
      filter -> Enum.filter(get_message_storage(), fn message -> message.message =~ filter end)
    end
  end
end
