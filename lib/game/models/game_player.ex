defmodule Game.Player do
  @type t() ::%__MODULE__{
    id: String.t,
    name: String.t,
    score: number,
    color: String.t
  }

  @enforce_keys [:id, :name, :score, :color]
  defstruct [:id, :name, :score, :color]

  @spec new(binary, binary) :: Game.Player.t()
  def new(id, name) when is_binary(id) and is_binary(name) do

    %Game.Player{
      id: id,
      name: name,
      score: 0,
      color: "red"
    }
  end

  @doc """
  takes player obj, and copies all propeties except id to target
  """
  def update(
    target = %Game.Player{},
    %Game.Player{name: name, score: score, color: color})do

    %{target | name: name, score: score, color: color}
  end
end
