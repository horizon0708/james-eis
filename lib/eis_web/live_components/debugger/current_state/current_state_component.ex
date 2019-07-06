defmodule EisWeb.CurrentStateComponent do
  use EisWeb.DebuggerComponent,
    group: "debugger"

  def assigns(%{game_state: game_state }) do
    game_state = Poison.encode!(game_state)
    |> Poison.decode!
    # ... I can't enum because its a struct %Game.State{}
    # but I can't do:
    # %{game_state: Map.from_struct(game_state)}
    # because apparently its not a struct?
    # what the fuck?
    # but serializing and deserializing works :shrug:


    %{game_state: game_state}
  end
end
