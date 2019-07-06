defmodule Game.BoardTest do
  use ExUnit.Case

  test "Gameboard setup" do
    config = generate_config(5, ["a","a","a","a"])
    board = Game.Board.build(config)
    expected = Enum.reverse([4, 0, 1, 2, 3])
    assert board == expected
  end

  test "more complicated Gameboard setup" do
    config = generate_config(20,  ["a","a","a","a"])
    board = Game.Board.build(config)
    expected = Enum.reverse([4, 0, 1, 2, 3, 4 ,0, 1, 2, 3, 4, 0, 1, 2,3, 4, 0,1,2,3])
    assert board == expected
  end

  defp generate_config(rounds_to_win, categories) do
    config = %Game.Config{
      host_id: "a",
      host_name: "a",
      turn_duration: 420,
      rounds_to_win: rounds_to_win,
      max_skip: 0,
      categories: categories
    }
  end

end
