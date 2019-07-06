defmodule Game.Network.ApiTests do
  use ExUnit.Case
  import Game.Command
  @compile {:parse_transform, :ms_transform}

  def setup do
    :ok
  end

  test "start, update and get current states" do
    Game.Network.Registry.start_link
    user_id = "a"
    game_id = Game.Network.Api.start_game(user_id)
    assert Game.Network.Api.get_current_state(user_id).name == "Jhon"
    Game.Network.Api.update_game(user_id, build(:change_name, ["alice"]))
    Game.Network.Api.update_game(user_id, build(:change_name, ["ben"]))
    Game.Network.Api.update_game(user_id, build(:change_name, ["charlie"]))
    assert Game.Network.Api.get_state_at(user_id, 1).name == "alice"
    assert Game.Network.Api.get_state_at(user_id, 2).name == "ben"

    Game.Network.Api.terminate_game(user_id)
    assert Game.Network.Api.get_current_state(user_id) == nil
  end
end
