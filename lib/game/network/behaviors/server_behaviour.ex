defmodule Game.Network.ServerBehaviour do
  @moduledoc """
  Internal module for Game Network
  """

  @type game_id :: String.t
  @type function_name :: atom
  @type args :: list


  @doc """
  Test
  """
  @callback get_game(game_id) :: Game.State | nil

  @callback update_game(game_id, module, function_name, args) :: :ok | :error
end
