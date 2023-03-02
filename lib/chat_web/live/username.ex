defmodule ChatWeb.Username do
  @moduledoc """
  This module loads animals(pokemons) and adjectives from static files to generate a random username,
  like in google services
  """

  @doc """
  Contains two (or more) static paths to lists of words, gets random words out of load_pick_random function
  and then jumbles them together into a username
  """
  def generate_username() do
    adjectives_and_animals = ["/priv/static/username_generation/adjectives.txt",
      "/priv/static/username_generation/animals.txt"]
    [adjective, animal] = Enum.map(adjectives_and_animals, &load_pick_random/1)
    "#{adjective} #{animal}"
  end

  @pdoc """
  Given a path, loads a file from it into stream, from which the function picks and returns a random word
  """
  defp load_pick_random(path) do
    File.stream!(Application.app_dir(:chat, path)) |> Enum.map(&String.trim/1) |> Enum.random()
  end

end