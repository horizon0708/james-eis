defmodule Game.Logic.OnGameUpdate do

  def player_wins_on_score(commands,
  %Game.State{players: players, config: %Game.Config{rounds_to_win: rounds_to_win}}) do
    highest_player = Game.Players.get_player_with_highest_score(players)
    if (highest_player.score >= rounds_to_win) do
      [ Game.Command.build(:game_win, [highest_player.id]) | commands ]
    else
      commands
    end
  end
end
