defmodule ChatWeb.Message do
  @moduledoc """
    module contains some logic regarding messages
  """
  @doc """
  basically creates a message struct
  """
  def create_message(username, message),
    do: %{
      time_stamp: create_timestamp(),
      username: username,
      message: message,
      id: UUID.uuid4(),
      likes: []
    }

  @doc """
  simple time_stamp creation that formats a datetime into a neat string
  """
  def create_timestamp(time \\ DateTime.utc_now()),
    do: Calendar.strftime(time, "%A %d-%m-%Y %H:%M:%S")
end
