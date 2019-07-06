defmodule EisWeb.LobbyComponent do
  use EisWeb.GameComponent

  def assigns(%{game_state: game_state=%Game.State{}}) do
    %{
      game_id: game_state.id,
      players: Game.State.get_players(game_state)
    }
  end
end
