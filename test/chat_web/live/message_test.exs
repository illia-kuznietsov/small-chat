defmodule ChatWeb.MessageTest do
  use ExUnit.Case, async: false

  test "create message" do
    message = ChatWeb.Message.create_message("illia", "hello")
    assert message["username"] == "illia"
    assert message["message"] == "hello"
    assert message["id"] != ""
    assert message["time_stamp"] != ""
  end

  test "correct format" do
    assert ChatWeb.Message.create_timestamp(~U[2000-02-08 00:00:00.000Z]) ==
             "Tuesday 08-02-2000 00:00:00"
  end
end
