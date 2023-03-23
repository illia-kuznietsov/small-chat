defmodule ChatWeb.Storage do
  alias Chat.{Repo, User, Message, Like}
  import Ecto.Changeset
  import Ecto.Query

  @moduledoc """
  Provides a small logic that revolves around storage of messages, users and their relations too
  """

  @doc """
  given a generated username, inserts user into the database
  """
  def save_user(username) do
    Repo.insert!(%User{username: username})
  end

  @doc """
  Provided given parameters, creates a message and puts it into message storage
  """
  def post_message(message, user_id, username) do
    message_struct = %Message{
      author_username: username,
      text_body: message,
      author: Repo.get!(User, user_id)
    }

    Repo.insert!(message_struct)
  end

  @doc """
  params contain id of the message that is supposed to be liked (or unliked) by a given user, so the list of usernames
  that liked the message gets updated
  """
  def update_message_likes(message_id, user_id) do
    message = Repo.get!(Chat.Message, message_id) |> Repo.preload([:likes])
    user = Repo.get(Chat.User, user_id) |> Repo.preload([:likes])

    case Enum.find(message.likes, fn like -> like.id == user.id end) do
      nil ->
        message
        |> change()
        |> put_assoc(:likes, [user | message.likes])
        |> Repo.update!()

      like ->
        query = from(l in Like, where: [user_id: ^like.id, message_id: ^message.id])

        Repo.one!(query)
        |> Repo.delete!()
    end
  end

end
