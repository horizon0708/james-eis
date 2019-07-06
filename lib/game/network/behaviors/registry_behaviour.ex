defmodule Game.Network.RegistryBehavior do
  @moduledoc """
  Internal module that maps user_id to game_id using :ets table
  :ets table is given to this table by RegistryBackup
  If this crashes, :ets tables goes back to RegistryBackup and is given back
  when this gets back up.
  """
  @type game_id :: String.t
  @type user_id :: String.t


  @moduledoc """
  Starts GenServers with DynamicSupervisor
  """
  @callback start_game(user_id) :: game_id | nil

  @callback get_game_id(user_id) :: game_id | nil

  @callback delete_users_from_game(game_id) :: :ok | :error

  @callback add_user_to_game(user_id, game_id) :: :ok | :error
end
