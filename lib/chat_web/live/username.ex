defmodule ChatWeb.Username do
  defp load_pick_random(path) do
    File.stream!(Application.app_dir(:chat, path)) |> Enum.map(&String.trim/1) |> Enum.random()
  end
  def generate_username() do
    adjectives_and_animals = ["/priv/static/username_generation/adjectives.txt",
      "/priv/static/username_generation/animals.txt"]
    [adjective, animal] = Enum.map(adjectives_and_animals, &load_pick_random/1)
    "#{adjective} #{animal}"
  end
end