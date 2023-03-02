defmodule ChatWeb.Storage do
  @moduledoc"""
  Provides a small logic of message storage, that is initialized with the start of the server, for now
  """

  @doc """
  Gets a list that represents message storage from Agent
  """
  def get_message_storage(), do: Agent.get(MessageStorage, fn list -> list |> Enum.reverse end)

  @doc """
  Provided given parameters, creates a message and puts it into message storage
  """
  def post_message(username, message, time_stamp, id) do
    Agent.update(MessageStorage, fn list ->
      [%{username: username, message: message, likes: [], time_stamp: time_stamp, id: id} | list] end)
  end

  @doc """
  params contain id of the message that is supposed to be liked (or unliked) by a given user, so the list of usernames
  that liked the message gets updated
  """
  def update_message_likes(params, username) do
    Agent.update(MessageStorage, fn list -> find_and_update_likes(list, params["id"], username) end)
  end

  @pdoc """
  gets a list of messages, finds a message by its id, and then updates the like count
  if the user already liked the message, the logic retracts the like (username) from the list
  """
  defp find_and_update_likes(list, id, username) do
    update_in(list, [Access.filter(&match?(%{id: ^id}, &1))], &Map.replace_lazy(&1, :likes, fn v ->
      if Enum.member?(v, username) do
        v -- [username]
      else
        [username | v]
      end
    end))
  end

end
