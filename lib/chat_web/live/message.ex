defmodule ChatWeb.Message do
  def create_message(username, message),
    do: %{
      "time_stamp" => create_timestamp(),
      "username" => username,
      "message" => message,
      "id" => UUID.uuid4()
    }

  defp create_timestamp(time \\ DateTime.utc_now()),
    do: Calendar.strftime(time, "%A %d-%m-%Y %H:%M:%S")
end
