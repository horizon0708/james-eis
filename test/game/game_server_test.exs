defmodule Game.Network.GameServerTest do
  use ExUnit.Case
  @compile {:parse_transform, :ms_transform}
  alias Game.Network.Server, as: GameServer

setup do
  %{game_id: "a"}
end

  test "get game with game_id: Success", %{game_id: game_id} do
    GameServer.start_link(game_id)
    state = GameServer.get_game(game_id)
    assert state.id == game_id
  end

  test "get game with game_id: Failure", %{game_id: game_id} do

  end

  test "get game with game_id at state: Success", %{game_id: game_id} do
    GameServer.start_link(game_id)
    Game.Network.Server.update_game(game_id, %Game.Command{
      sender: :system,
      module: Game.Logic,
      function: :change_name,
      args: ["A"]
    })
    Game.Network.Server.update_game(game_id, %Game.Command{
      sender: :system,
      module: Game.Logic,
      function: :change_name,
      args: ["B"]
    })
    Game.Network.Server.update_game(game_id, %Game.Command{
      sender: :system,
      module: Game.Logic,
      function: :change_name,
      args: ["C"]
    })
    Game.Network.Server.update_game(game_id, %Game.Command{
      sender: :system,
      module: Game.Logic,
      function: :change_name,
      args: ["D"]
    })
    state_1 = Game.Network.Server.get_game(game_id, 1)
    assert state_1.name == "A"
    state_2 = Game.Network.Server.get_game(game_id, 2)
    assert state_2.name == "B"
    state_3 = Game.Network.Server.get_game(game_id, 3)
    assert state_3.name == "C"
  end

  test "get game with game_id at state: Failure", %{game_id: game_id} do

  end

  # test "update game", %{game_id: game_id} do
  #   GameServer.start_link(game_id)
  #   Game.Network.Server.update_game(game_id, Elixir.Game.Logic, :change_name, ["A"])
  #   state = Game.Network.Server.get_game(game_id)
  #   assert state.name == "A"
  # end

  # test "fail to update game", %{game_id: game_id} do
  #   GameServer.start_link(game_id)
  #   assert_raise(UndefinedFunctionError, Game.Network.Server.update_game(game_id, Elixir.Game.Logic, :doesnt_exist, ["A"]))
  # end
end
