defmodule Game.Players do
  @moduledoc """
  probably not the best way to do this, not elegant enough
  need to read document to know wtf this guy does
  """

  @limit 4
  @type t(something) :: %__MODULE__{
          internal: something,
          current_index: number,
          previous_index: number,
          order: list(String.t())
        }

  defstruct internal: %{},
            current_index: 0,
            previous_index: 0,
            order: []

  @doc """
  success -> adds a player with default name "Team [NUMBER]".
  failure -> returns same Players map when the player limit is reached
  """
  @spec add_player(Game.Players.t(), String.t()) :: Game.Players.t()
  def add_player(%Game.Players{order: order, internal: internal} = map, user_id) do
    if length(map.order) + 1 > @limit do
      map
    else
      new_player = Game.Player.new(user_id, "Team #{length(map.order) + 1}")

      internal = Map.put(internal, new_player.id, new_player)
      test_order = [new_player.id | order]
      %{map | internal: internal, order: test_order}
    end
  end

  @doc """
  gets the score with highest score
  """
  def get_player_with_highest_score(%Game.Players{}= players) do
    get_players_list(players)
    |> Enum.max_by(fn x -> x.score end)
  end

  def set_name(%Game.Players{} = map, user_id, name) do
    with {:ok, player} <- Map.fetch(map.internal, user_id) do
      updated_player = %{player | name: name}
      update(map, updated_player)
    else
      _ -> :error
    end
  end

  def increment_score(
        map = %Game.Players{internal: internal},
        player_id,
        score_to_add \\ 1
      )
      when is_binary(player_id) do
    player = Map.fetch!(internal, player_id)
    player = %{player | score: player.score + score_to_add}
    update(map, player)
  end

  @spec get_players_list(Game.Players.t()) :: [Game.Player.t()]
  def get_players_list(%Game.Players{internal: internal}) do
    Enum.map(internal, fn {_k, v} -> v end)
  end

  def get_players_name(players = %Game.Players{}) do
    get_players_list(players)
    |> Enum.map(fn player -> player.name end)
  end

  def name_exists?(players = %Game.Players{}, name) do
    get_players_name(players)
    |> Enum.member?(name)
  end

  @spec update_current(Game.Players.t(), Game.Player.t()) :: Game.Players.t()
  def update_current(map = %Game.Players{}, obj = %Game.Player{}) do
    player =
      current(map)
      |> Game.Player.update(obj)

    update(map, player)
  end

  @spec update(Game.Players.t(), Game.Player.t()) :: Game.Players.t()
  defp update(map = %Game.Players{internal: internal}, %Game.Player{} = player) do
    internal = Map.put(internal, player.id, player)
    Map.put(map, :internal, internal)
  end

  @spec current(Game.Players.t()) :: Game.Player.t() | nil
  def current(%Game.Players{order: order, current_index: current_index, internal: internal}) do
    with {:ok, key} <- Enum.fetch(order, current_index),
         {:ok, player} <- Map.fetch(internal, key) do
      player
    else
      _ -> nil
    end
  end

  @spec next(Game.Players.t()) :: Game.Players.t()
  def next(%Game.Players{} = map) do
    next_index =
      if map.current_index + 1 > length(map.order) - 1 do
        0
      else
        map.current_index + 1
      end

    %{map | previous_index: map.current_index, current_index: next_index}
  end

  @spec jump(Game.Players.t(), number) :: Game.Players.t()
  def jump(%Game.Players{} = map, jump_index) do
    next_number =
      if jump_index > length(map.internal_list) - 1 do
        length(map.internal_list) - 1
      else
        jump_index
      end

    %{map | previous_index: map.current_index, current_index: next_number}
  end

  @spec previous(Game.Players.t()) :: Game.Players.t()
  def previous(%Game.Players{} = map) do
    %{map | current_index: map.previous_index, previous_index: map.current_index}
  end
end
