defmodule EisWeb.DebuggerPageComponent do
  use EisWeb.DebuggerComponent,
    group: "debugger"

  def assigns(%{game_state: game_state=%Game.State{}}) do
    game_state = Poison.encode!(game_state)
    %{game_state: game_state}
  end
end
