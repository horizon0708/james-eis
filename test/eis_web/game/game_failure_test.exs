# defmodule EisWeb.GameFailureTest do
#   use ExUnit.Case
#   doctest EisWeb.GameRegistry
#   alias EisWeb.GameRegistry, as: GameRegistry
#   alias EisWeb.GameServer, as: GameServer
#   @compile {:parse_transform, :ms_transform}


#   #how to ignore EisWeb.Application
#   # https://virviil.github.io/2016/10/26/elixir-testing-without-starting-supervision-tree/

#   setup do
#     if Process.whereis(EisWeb.GameSupervisor != nil) do
#       DynamicSupervisor.stop(EisWeb.GameSupervisor)
#     end
#     start_supervised!(EisWeb.GameBackup)
#     start_supervised!({DynamicSupervisor, [name: EisWeb.GameSupervisor, strategy: :one_for_one, restart: :transient]})
#     start_supervised!(GameRegistry)
#     start_supervised!(EisWeb.RegistryBackup)

#     :ok
#   end

#   #https://github.com/paulanthonywilson/gproc_select_examples/blob/master/test/gproc_select_test.exs
#   @tag :no_app
#   test "When a game server crashes, it is restarted, the new server retains the gamestate"   do
#     user_a = "a"
#     user_b = "b"
#     game_id = GameRegistry.start_game( user_a)
#     GameRegistry.start_game( user_b)
#     # GameServer.update(game_id, &EisWeb.GameLogic.change_name/2, ["Alice"])
#     GameServer.update(game_id, {EisWeb.GameLogic, :change_name, ["Alice"]})

#     assert(Enum.count(get_all_gproc()) == 2)

#     get_pid(game_id)
#     |> Process.exit(:kill)
#     :timer.sleep(10)

#     assert(Enum.count(get_all_gproc()) == 2)
#     assert(Enum.count(get_all_games_ets()) == 2)

#     # inspect game state
#     restarted_game = GameServer.get(game_id)
#     assert restarted_game.id == game_id
#     assert restarted_game.name == "Alice"
#     IO.puts restarted_game.name

#   end

#   defp get_all_gproc() do
#     matcher = :ets.fun2ms(fn x -> x end)
#     :gproc.select(matcher)
#   end

#   defp get_all_games_ets() do
#     :ets.match(:user_to_game, {:"$1", :"$2"})
#   end

#   #https://stackoverflow.com/questions/26809391/erlang-how-to-deal-with-long-running-init-callback

#   @tag :no_app
#   test "When a game server exits normally, it is not restarted and ets is updated"  do
#     user_a = "a"
#     user_b = "b"

#     game_id = GameRegistry.start_game( user_a)
#     GameRegistry.start_game( user_b)

#     assert(Enum.count(get_all_gproc()) == 2)
#     assert(Enum.count(get_all_games_ets()) == 2)

#     GameRegistry.stop_game( game_id)
#     :timer.sleep(10)

#     assert(Enum.count(get_all_gproc()) == 1)
#     assert(Enum.count(get_all_games_ets()) == 1)
#   end

#   @tag :no_app
#   test "When GameRegistry crashes, it is restarted and it retains the ets table" do
#     user_a = "a"
#     user_b = "b"
#     GameRegistry.start_game( user_a)
#     GameRegistry.start_game( user_b)

#     assert(Enum.count(get_all_gproc()) == 2)
#     assert(Enum.count(get_all_games_ets()) == 2)

#     Process.whereis(GameRegistry)
#     |> Process.exit(:kill)
#     :timer.sleep(10)

#     assert(Enum.count(get_all_gproc()) == 2)
#     assert(Enum.count(get_all_games_ets()) == 2)
#   end

#   defp get_pid(game_id) do
#     :gproc.where({:n, :l, {:game, game_id}})
#   end
# end
