defmodule Game.Network.Helper do
  @moduledoc """
  Module with utility functions
  """

  def via_tuple(game_id) do
    {:via, :gproc, {:n, :l, {:game, game_id}}}
  end

  def via_tuple(category, game_id) when is_atom(category) and is_binary(game_id) do
    {:via, :gproc, {:n, :l, {category, game_id}}}
  end

  def get_supervisor_id(game_id) do
    {:via, :gproc, {:n, :l, {:game_supervisor, game_id}}}
  end

  def get_timer_id(game_id) do
    {:via, :gproc, {:n, :l, {:game_timer, game_id}}}
  end
end
