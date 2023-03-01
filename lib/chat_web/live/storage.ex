defmodule ChatWeb.Storage do

  def get_message_storage(), do: Agent.get(MessageStorage, fn list -> list |> Enum.reverse end)

  def post_message(username, message, time_stamp, id) do
    Agent.update(MessageStorage, fn list ->
      [%{username: username, message: message, likes: [], time_stamp: time_stamp, id: id} | list] end)
  end

  def update_message_likes(params, username) do
    Agent.update(MessageStorage, fn list -> find_and_update_likes(list, params["id"], username) end)
  end

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
