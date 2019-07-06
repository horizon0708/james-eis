defmodule Game.Network.Api do
  # @behaviour Game.Network.ApiBehavior
  use Game.Command

  @typedoc """
  Anyone interacting with the game should ONLY interact with this logic
  Therefore, the errors should have meaningful messages
  """

  @game_supervisor :game_supervisor
  @type user_id :: String.t()
  @type game_id :: String.t()
  @type module_name :: atom
  @type function_name :: atom
  @type args :: list
  @type state_index :: number

  # Pre-game ===========================

  @doc """
  Start the GenServer that hosts the server. Puts the game into Lobby
  """
  def start_game(user_id) do
    result = DynamicSupervisor.start_child(@game_supervisor, {Game.Network.Supervisor, user_id})

    with {:ok, _} <- result do
      user_id
    else
      _ -> nil
    end
  end

  def player_name_exists?(user_id, name) do
    case get_current_state(user_id) do
      nil -> nil
      state -> Game.State.name_exists?(state, name)
    end
  end

  def change_player_name(user_id, name) do
    case get_current_state(user_id) do
      nil -> :error
      state -> {:ok, Game.State.change_name(state, user_id, name)}
    end
  end

  def add_user_to_game(user_id, game_id) do
    with :ok <- Game.Network.Registry.add_user_to_game(user_id, game_id),
         :ok <-
           Game.Command.build(:add_player, [user_id])
           |> update_game(user_id) do
         :ok
    else
      {:error, msg} -> {:error, msg}
      _ -> raise "ets insert error"
    end
  end

  # === In game ===

  def increment_score(user_id)  do
    build(:increment_player_score, [user_id], user_id)
    |> update_game(user_id)
  end


  @spec terminate_game(user_id) :: :ok | :error
  def terminate_game(user_id) do
    game_id = Game.Network.Registry.get_game_id(user_id)

    case get_pid(game_id) do
      :undefined ->
        :error

      pid ->
        DynamicSupervisor.terminate_child(@game_supervisor, pid)
        :ok
    end
  end

  def update_game(%Game.Command{} = command, user_id) do
    Game.Network.Registry.get_game_id(user_id)
    |> Game.Network.Server.update_game(command)
  end

  @doc """
  Find game with game_id and update the game, only should only be used by debugger
  """
  def update_game_with_game_id(%Game.Command{} = command, game_id) do
    Game.Network.Server.update_game(game_id, command)
  end

  def get_game(game_id) do
    Game.Network.Server.get_game(game_id)
  end

  def register_component(game_id) do
    Game.Network.Registry.register_component(game_id)
  end

  @spec get_current_state(user_id) :: Game.State.t() | nil
  def get_current_state(user_id) when is_binary(user_id) do
    Game.Network.Registry.get_game_id(user_id)
    |> Game.Network.Server.get_game()
  end

  def get_current_state(_user_id) do
    nil
  end

  @spec get_state_at(user_id, state_index) :: any | nil
  def get_state_at(user_id, state_index) do
    Game.Network.Registry.get_game_id(user_id)
    |> Game.Network.Server.get_game(state_index)
  end

  defp get_pid(game_id) do
    :gproc.where({:n, :l, {:game_supervisor, game_id}})
  end
end
