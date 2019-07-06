defmodule Game.Network.GameRegistryTest do
  use ExUnit.Case
  @compile {:parse_transform, :ms_transform}

  setup do
    Game.Network.Registry.start_link()
    user_id = "a"
    game_id = Game.Network.Registry.start_game(user_id)
    %{user_id: user_id, game_id: game_id}
  end

  test "start game" do
    assert length(get_all_games_ets) == 1
  end

  test "get id", %{user_id: user_id, game_id: game_id} do
    assert Game.Network.Registry.get_game_id(user_id) == game_id
  end

  test "add / delete users", %{game_id: game_id}do
    Game.Network.Registry.add_user_to_game("b", game_id)
    Game.Network.Registry.add_user_to_game("c", game_id)
    Game.Network.Registry.add_user_to_game("d", game_id)

    assert length(get_all_games_ets) == 4

    Game.Network.Registry.delete_users_from_table(game_id)

    assert length(get_all_games_ets) == 0
  end

  defp get_all_games_ets() do
    :ets.match(:user_to_game, {:"$1", :"$2"})
  end

  # TODO Test back up/ give away later
end
