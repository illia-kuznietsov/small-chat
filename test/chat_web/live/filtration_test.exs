defmodule ChatWeb.FiltrationTest do
  use ExUnit.Case, async: false

  test "test filters" do
    ChatWeb.Message.create_message("testuser", "testmessage") |> ChatWeb.Storage.post_message()

    ChatWeb.Message.create_message("testuser_v2", "testmessage2")
    |> ChatWeb.Storage.post_message()

    ChatWeb.Message.create_message("testuser_v3", "testmessage3")
    |> ChatWeb.Storage.post_message()

    [first, second, third | _] = ChatWeb.Storage.get_message_storage()

    ChatWeb.Storage.update_message_likes(first.id, "testuser")

    # got one liked message
    assert ChatWeb.Filtration.filter_messages("", %{"only-liked" => "on"}) ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.likes != [] end
             )

    # testing if it has passed the text filter as well as the first checkbox filter
    assert ChatWeb.Filtration.filter_messages("te", %{"only-liked" => "on"}) ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.likes != [] and message.message =~ "te" end
             )

    # this way we are retracting the like
    ChatWeb.Storage.update_message_likes(first.id, "testuser")
    # checking that this indeed happened
    assert ChatWeb.Filtration.filter_messages("te", %{"only-liked" => "on"}) == []
    # checking filtration with no filtration params
    assert ChatWeb.Filtration.filter_messages("", %{"only-liked" => "off"}) ==
             ChatWeb.Storage.get_message_storage()

    # checking only text filter
    assert ChatWeb.Filtration.filter_messages("te", %{"only-liked" => "off"}) ==
             Enum.filter(
               ChatWeb.Storage.get_message_storage(),
               fn message -> message.message =~ "te" end
             )

    # checking not implemented checkbox filters
    assert ChatWeb.Filtration.filter_messages("", %{"not-implemented" => "on"}) ==
             ChatWeb.Storage.get_message_storage()

    # checking second checkbox filter, where the messages have a like from a user that liked more than one message
    ChatWeb.Storage.update_message_likes(first.id, "testuser")
    ChatWeb.Storage.update_message_likes(second.id, "testuser")
    assert length(ChatWeb.Filtration.filter_messages("", %{"liked-by-likers" => "on"})) == 2

    # checking third checkbox filter, where the messages have no likes and come from users that didn't like anything
    [expected | _] = ChatWeb.Filtration.filter_messages("", %{"not-liked-by-nonlikers" => "on"})
    assert expected.message == "testmessage3"
    # checking the forth filter, where 80%+ of ALL likes belong to the least amount of messages
    ChatWeb.Storage.update_message_likes(third.id, "testuser")

    assert length(
             ChatWeb.Filtration.filter_messages("", %{"20-percent-minority-most-liked" => "on"})
           ) == 3

    ChatWeb.Storage.update_message_likes(second.id, "testuser_v1")
    ChatWeb.Storage.update_message_likes(third.id, "testuser_v1")

    assert length(
             ChatWeb.Filtration.filter_messages("", %{"20-percent-minority-most-liked" => "on"})
           ) == 2
  end
end
