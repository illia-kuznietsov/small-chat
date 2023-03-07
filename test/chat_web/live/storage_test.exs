defmodule ChatWeb.StorageTest do
  use ExUnit.Case, async: false

  test "get_message_storage" do
    assert is_list(ChatWeb.Storage.get_message_storage())
  end

  test "new message" do
    ChatWeb.Storage.post_message("testuser", "testmessage", "datetime", "testid")

    assert %{
             username: "testuser",
             message: "testmessage",
             likes: [],
             time_stamp: "datetime",
             id: "testid"
           } in ChatWeb.Storage.get_message_storage()
  end

  test "like, then dislike" do
    ChatWeb.Storage.post_message("testuser", "testmessage", "datetime", "testid")

    ChatWeb.Storage.update_message_likes("testid", "testuser")

    assert %{
             username: "testuser",
             message: "testmessage",
             likes: ["testuser"],
             time_stamp: "datetime",
             id: "testid"
           } in ChatWeb.Storage.get_message_storage()

    ChatWeb.Storage.update_message_likes("testid", "testuser")

    assert %{
             username: "testuser",
             message: "testmessage",
             likes: [],
             time_stamp: "datetime",
             id: "testid"
           } in ChatWeb.Storage.get_message_storage()
  end
end
