defmodule ChatWeb.StorageTest do
  use ExUnit.Case, async: false

  test "get_message_storage" do
    assert is_list(ChatWeb.Storage.get_message_storage())
  end

  test "new message" do
    ChatWeb.Message.create_message("testuser", "testmessage") |> ChatWeb.Storage.post_message()

    assert Enum.any?(ChatWeb.Storage.get_message_storage(), fn message ->
             message.username == "testuser"
           end)
  end

  test "like, then dislike" do
    ChatWeb.Message.create_message("testuser", "testmessage") |> ChatWeb.Storage.post_message()
    [first | _] = ChatWeb.Storage.get_message_storage()

    ChatWeb.Storage.update_message_likes(first.id, "blah")

    assert Enum.any?(ChatWeb.Storage.get_message_storage(), fn message ->
             "blah" in message.likes
           end)

    ChatWeb.Storage.update_message_likes(first.id, "blah")

    assert Enum.any?(ChatWeb.Storage.get_message_storage(), fn message -> "blah" not in message.likes end)
  end
end
