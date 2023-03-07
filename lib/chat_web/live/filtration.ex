defmodule ChatWeb.Filtration do
  import ChatWeb.Storage

  def filter_messages(text, "on"),
    do:
      Enum.filter(filtrate_on_text(text), fn message ->
        length(message.likes) > 0
      end)

  def filter_messages(text, "off"), do: filtrate_on_text(text)

  defp filtrate_on_text(text) do
    case text do
      "" -> get_message_storage()
      filter -> Enum.filter(get_message_storage(), fn message -> message.message =~ filter end)
    end
  end
end
