defmodule ChatWeb.Storage do
  alias Chat.Repo
  import Ecto.Changeset

  @moduledoc """
  Provides a small logic of message storage, that is initialized with the start of the server, for now
  """

  @doc """
  Gets a list that represents message storage from Agent
  """
  def get_message_storage(), do: Repo.all(Chat.Message) |> Repo.preload([:likes])

  @doc """
  Provided given parameters, creates a message and puts it into message storage
  """
  def post_message(message) do
    Repo.insert!(message)
  end

  @doc """
  params contain id of the message that is supposed to be liked (or unliked) by a given user, so the list of usernames
  that liked the message gets updated
  """
  def update_message_likes(message_id, user_id) do
    message = Repo.get!(Chat.Message, message_id) |> Repo.preload([:likes])
    user = Repo.get(Chat.User, user_id) |> Repo.preload([:likes])
    IO.inspect(message, label: "message : ")
    params = %{likes: [user | message.likes]}
    IO.inspect(params, label: "params : ")
    message
    |> cast(params, [])
    |> cast_assoc(:likes, [user | message.likes])
    |> IO.inspect(label: "message now : ")
#    case Enum.find(message.likes, fn like -> like.username == user.username end) do
#      nil ->
#        like = %Chat.User{username: user.username}
#        params = %{likes: [like | message.likes]}
#        message
#        |> Ecto.Changeset.cast(params, [])
#        |> Ecto.Changeset.cast_assoc(likes)
#
#
#
#      like ->
#        like_id = like.id
#        message_id = message.id
#
#        query =
#          "SELECT ml.id FROM message_like as ml WHERE ml.like_id = #{like_id} AND ml.message_id = #{message_id};"
#
#        result = Repo.query!(query)
#
#        result.rows
#        |> List.flatten()
#        |> Enum.fetch!(0)
#        |> then(&Repo.get!(Chat.MessageLike, &1))
#        |> Repo.delete!()
#    end
  end

  # gets a list of messages, finds a message by its id, and then updates the like count
  # if the user already liked the message, the logic retracts the like (username) from the list
  #  defp find_and_update_likes(list, id, username) do
  #    update_in(
  #      list,
  #      [Access.filter(&match?(%{id: ^id}, &1))],
  #      &Map.replace_lazy(&1, :likes, fn v ->
  #        if Enum.member?(v, username) do
  #          v -- [username]
  #        else
  #          [username | v]
  #        end
  #      end)
  #    )
  #  end
end
