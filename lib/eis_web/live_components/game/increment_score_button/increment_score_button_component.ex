defmodule EisWeb.IncrementScoreButtonComponent do
  use EisWeb.GameComponent, "game"

  def assigns(game_state) do
    %{}
  end

  def handle_event("onclick", _, socket) do
    Game.Network.Api.
  end
end
