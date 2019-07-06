defmodule Game.Logic do
  use Game.State

  @spec wrap(atom, maybe_improper_list) :: {EisWeb.GameLogic, atom, maybe_improper_list}
  def wrap(function_name, args) when is_atom(function_name) and is_list(args) do
    {EisWeb.GameLogic, function_name, args}
  end

  def change_name(state = %Game.State{}, args = [name]) when is_list(args) do
    %{state | name: name}
  end

  # TODO: meta programming to reduce the clutter here
  def change_status(state = %Game.State{}, args = [new_status]) when is_list(args) do
    %{state | game_status: new_status}
  end

  def start_lobby(_state, args = [game_config, game_id]) when is_list(args) do
    Game.State.start_lobby(game_config, game_id)
  end

  def add_player(game_state=%Game.State{}, [player_id]) do
    Game.State.add_player(game_state, player_id)
  end

  def start_game(state =%Game.State{}, args = [game_config]) when is_list(args) do

  end

  def game_win(game_state, [player_id]) do
      Game.State.update_game_status(game_state, {:ended, player_id})
  end

  def increment_score(game_state, [player_id]) do
    increment_player_score(game_state, player_id)
  end
end
