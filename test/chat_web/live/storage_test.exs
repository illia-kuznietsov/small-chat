defmodule ChatWeb.StorageTest do
  use ExUnit.Case, async: false
  use Chat.RepoCase
  alias ChatWeb.Storage


  test "saving user works, then posting a message, and checking if likes work" do
    # saving our first (?) user
    user = Storage.save_user("test_user_1")
    assert user.username == "test_user_1"
    # this user posts their first message
    message = Storage.post_message("test message", user.id, user.username)
    assert message.author == user
    assert message.text_body == "test message"
    # checking this message's likes being empty first
    message = message |> Repo.preload(:likes)
    assert message.likes == []
    # user liked their own message!
    message = Storage.update_message_likes(message.id, user.id)
    assert message.likes != []
    # user has changed their mind
    message = Storage.update_message_likes(message.id, user.id)
    assert message.likes == []
  end
end
