defmodule Game.Network.ApiBehavior do
  @moduledoc """
  public interface for interaction
  """

  @type game_id :: String.t
  @type user_id :: String.t
  @type module_name :: atom
  @type function_name :: atom
  @type args :: list
  @type state_index :: number

  @doc """
  Spins up a new game using DynamicSupervisor
  """
  @callback start_game(user_id) :: game_id | nil

  @doc """
  Terminates all related GenServers for the game. If you are just putting the game into
  end state, use update_game/4
  """
  @callback terminate_game(user_id) :: :ok | :error

  @doc """
  Updates the game state with given the function in GameLogic module.
  """
  @callback update_game(Game.Command.t, user_id) :: :ok | :error

  @doc """
  Gets the current game state
  """
  @callback get_current_state(user_id) :: any | nil

  @doc """
  Gets the game state at [state index]. Skips minor game state events (timer events).
  """
  @callback get_state_at(user_id, state_index) :: any | nil
end
