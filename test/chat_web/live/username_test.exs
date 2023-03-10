defmodule ChatWeb.UsernameTest do
  use ExUnit.Case

  test "generate username" do
    testusername = ChatWeb.Username.generate_username()
    assert length(String.split(testusername, " ")) >= 2
  end
end
