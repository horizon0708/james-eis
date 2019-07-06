defmodule EisWeb.ScoreBoardComponent do
  use EisWeb.GameComponent, "game"

  def assigns(%{game_state: game_state =
    %Game.State{players: players}) do
      scores = Game.Players.get_players_list(players)
      |> Enum.map(fn player -> {player.name, player.score} end)
      %{scores: scores}
  end
end
