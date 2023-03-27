defmodule ChatWeb.FiltrationTest do
  use ExUnit.Case, async: false
  use Chat.RepoCase
  alias ChatWeb.{Storage, Filtration}
  alias Chat.Message

  test "test filters" do
    # create some users
    user_1 = Storage.save_user("test_user_1")
    user_2 = Storage.save_user("test_user_2")
    user_3 = Storage.save_user("test_user_3")

    # users post their first messages
    message_1 = Storage.post_message("hello all", user_1.id, user_1.username)
    message_2 = Storage.post_message("hello, test_user_1!", user_2.id, user_2.username)
    message_3 = Storage.post_message("hello indeed", user_3.id, user_3.username)

    #user_1 liked their message
    ChatWeb.Storage.update_message_likes(message_1.id, user_1.id)

    # checking that filters got one liked message
    [first_filtered | _] = Filtration.filter_messages("", %{"only-liked" => "on"})
    assert first_filtered.text_body == "hello all"

    # testing if it has not passed passed the text filter tho, despite passing the first checkbox filter
    assert Filtration.filter_messages("te", %{"only-liked" => "on"}) == []

    # this way we are retracting the like
    Storage.update_message_likes(message_1.id, user_1.id)

    # checking that this indeed happened
    assert Filtration.filter_messages("", %{"only-liked" => "on"}) == []

    # checking filtration with no filtration params
    assert Filtration.filter_messages("", %{}) == Repo.all(Message) |> Repo.preload([:likes])

    # checking only text filter
    [first_filtered | _] = Filtration.filter_messages("indeed", %{"only-liked" => "off"})
    assert first_filtered.text_body == "hello indeed"

    # checking not implemented checkbox filters
    assert ChatWeb.Filtration.filter_messages("", %{"not-implemented" => "on"}) == Repo.all(Message) |> Repo.preload([:likes])

    # checking second checkbox filter, where the messages have a like from a user that liked more than one message
    ChatWeb.Storage.update_message_likes(message_1.id, user_1.id)
    ChatWeb.Storage.update_message_likes(message_2.id, user_1.id)
    assert length(ChatWeb.Filtration.filter_messages("", %{"liked-by-likers" => "on"})) == 2

    # checking third checkbox filter, where the messages have no likes and come from users that didn't like anything
    [expected | _] = ChatWeb.Filtration.filter_messages("", %{"not-liked-by-nonlikers" => "on"})
    assert expected.text_body == "hello indeed"

    # checking the forth filter, where 80%+ of ALL likes belong to the least amount of messages
    ChatWeb.Storage.update_message_likes(message_3.id, user_3.id)

    assert length(
             ChatWeb.Filtration.filter_messages("", %{"20-percent-minority-most-liked" => "on"})
           ) == 3
  end
end
