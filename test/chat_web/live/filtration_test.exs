defmodule ChatWeb.FiltrationTest do
  use ExUnit.Case, async: false

  test "test filters" do
    ChatWeb.Message.create_message("testuser", "testmessage") |> ChatWeb.Storage.post_message()

    [first | _] = ChatWeb.Storage.get_message_storage()

    ChatWeb.Storage.update_message_likes(first.id, "testuser")

    assert ChatWeb.Filtration.filter_messages("", "on") ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.likes != [] end
             )

    assert ChatWeb.Filtration.filter_messages("te", "on") ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.likes != [] and message.message =~ "te" end
             )

    ChatWeb.Storage.update_message_likes(first.id, "testuser")

    assert ChatWeb.Filtration.filter_messages("te", "on") == []

    assert ChatWeb.Filtration.filter_messages("", "off") == ChatWeb.Storage.get_message_storage()

    assert ChatWeb.Filtration.filter_messages("te", "off") ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.message =~ "te" end
             )
  end
end
