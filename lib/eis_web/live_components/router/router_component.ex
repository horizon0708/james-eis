defmodule EisWeb.RouterComponent do
  use EisWeb.ComponentBase


  def assigns(%{game_state: game_state = %Game.State{}}) do
    %{game_status: game_state.game_status}
  end
  def assigns(_game_state) do
    %{game_status: "a"}
  end
end
