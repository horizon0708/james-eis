defmodule Game.Category do

  @type t() ::%__MODULE__{
    name: String.t,
    words: list(Game.Word),
    current_index: number
  }

  @enforce_keys [:name, :words]
  defstruct name: "",
    words: [],
    current_index: 0

  @spec get_word(%Game.Category{}) :: Game.Word | nil
  def get_word(%Game.Category{} = category) do
    Enum.at(category.words, category.current_index)
  end

  # if you try to access over list length, it will silently fail with nil
  @spec next_word(%Game.Category{}) :: Game.Word | nil
  def next_word(%Game.Category{} = category) do
    get_word(%{ category | current_index: category.current_index + 1})
  end
end
