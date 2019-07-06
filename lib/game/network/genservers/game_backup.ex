defmodule EisWeb.GameBackup do
  use GenServer
  import Game.Network.Helper

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(:game_backup, game_id))
  end

  @spec get(binary()) :: %Game.State{} | nil
  def get(game_id) when is_binary(game_id) do
    try do
      GenServer.call(via_tuple(:game_backup, game_id), {:get, game_id})
    rescue
      _ -> nil
    end
  end

  @spec update(binary(), any()) :: :ok | :error
  def update(game_id, state) when is_binary(game_id) do
    try do
      GenServer.call(via_tuple(:game_backup,game_id), {:update, game_id, state})
    rescue
      _ -> :error
    end
  end

  @spec delete(binary()) :: :ok | :error
  def delete(game_id) when is_binary(game_id) do
    try do
    GenServer.call(via_tuple(:game_backup, game_id), {:delete, game_id})
    rescue
      _ -> :error
    end
  end


  # -- server --
  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:get, game_id}, _from, state) do
    game_state = case state do
      nil -> nil
      _ -> Map.get(state, game_id)
    end
    {:reply, game_state, state}
  end

  def handle_call({:update, game_id, game_state},_from, state) do
    IO.puts "updated"
    new_state = Map.put(state, game_id, game_state)
    {:reply, :ok, new_state}
  end

  def handle_call({:delete, game_id},_from, state) do
    new_state = Map.delete(state, game_id)
    {:reply, :ok, new_state}
  end
end
