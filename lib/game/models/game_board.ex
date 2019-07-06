defmodule Game.Board do
  @moduledoc """
  maps player score to category index
  uses a generic list for now.
  """


  @doc """
  builds the board from game config. The end square must be All Play.
  """
  @spec build(Game.Config.t) :: Game.Board.t
  def build(%Game.Config{} = config) do
    categories_length = length(config.categories)
    # we start from length point (All Play) to generate, and then flip them around
    generate_board(categories_length, config.rounds_to_win - 1, [], categories_length)
  end

  defp generate_board(category_length, board_size, list, current_index) do
    list = [ current_index | list ]
    current_index = iterate_board_type_in_loop(category_length, current_index)
    board_size = board_size - 1
    if board_size < 0 do
      list
    else
      generate_board(category_length, board_size, list, current_index)
    end
  end

  defp iterate_board_type_in_loop(max, current_index) do
    next_index = current_index + 1
    if next_index > max  do
      0
    else
      next_index
    end
  end
end
