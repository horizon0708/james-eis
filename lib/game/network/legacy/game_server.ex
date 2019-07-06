defmodule EisWeb.GameServer do
  use GenServer
  alias Game.State

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end


  defp via_tuple(game_id) do
    {:via, :gproc, {:n, :l, {:game, game_id}}}
  end

  #https://elixirforum.com/t/can-you-rescue-catch-process-exits-in-a-task/16439/2
  def get(game_id) do
    try do
      GenServer.call(via_tuple(game_id), { :get })
    catch
      :exit, _ -> nil
    end
  end

  # test passing in function
  @spec update(binary(), fun(), maybe_improper_list()) :: any()
  def update(game_id, func, args) when is_binary(game_id) and is_function(func) and is_list(args) do
    try do
    new_state = GenServer.call(via_tuple(game_id), {:update, func, args})
    catch
    :exit, _-> :error
    end
  end

  def update(game_id, function_args = {module_name, function_name, args})
  when is_binary(game_id) and is_atom(module_name) and is_atom(function_name) and is_list(args) do
    try do
      new_state = GenServer.call(via_tuple(game_id), {:update, function_args})
    catch
     :exit, _ -> :error
    end
  end


  def broadcast(game_id, new_state) do
    key = {:p, :l, {:broadcast, game_id}}
    data = {:state_updated, new_state}
    :gproc.send(key, data)
    :ok
  end

  def stop(game_id) do


  end

  @doc """
  Ensures there is a buckt associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks

  def init(game_id) do
    new_game = Map.put(%Game.State{id: nil}, :id, game_id)
    case retry_get(game_id) do
      nil ->
        {:ok, new_game}
      game_state ->
        IO.puts "reloading game state"
        {:ok, game_state}
    end
  end


  defp retry_get(_, _retry = 0), do: nil
  defp retry_get(game_id, retry \\ 3) do
    case EisWeb.GameBackup.get(game_id) do
      nil ->
        :timer.sleep(10)
        retry_get(game_id, retry - 1)
      game_state ->
        game_state
    end
  end



  def handle_call({:stop}, _from, state) do
    {:stop, :normal, state}
  end

  def handle_call({:get}, _from, gameState) do
    {:reply, gameState, gameState}
  end

  def handle_call({:lookup, _name}, _from, Game.State) do
    {:reply, Game.State, Game.State}
  end

  def handle_call({:update, func, args},_from, game_state) when is_function(func) and is_list(args) do
    updated = func.(game_state, args)
    if game_state.id != nil do
      EisWeb.GameBackup.update(game_state.id, updated)
      broadcast(game_state.id, updated)
    end
    {:reply, updated, updated}
  end

  def handle_call({:update, {module_name, function_name, args}},_from, game_state) do
    updated = apply(module_name, function_name, [game_state | [args]])
    if game_state.id != nil do
      EisWeb.GameBackup.update(game_state.id, updated)
      broadcast(game_state.id, updated)
    end
    {:reply, updated, updated}
  end
  # handle_continue ??

  def handle_info({:EXIT, _from, reason}, state) do
    IO.puts "EXIT "
    {:stop, reason, state} # see GenServer docs for other return types
  end

  def terminate(reason, state) do
    IO.puts "Going Down!"
    :normal
  end
  #terminate to clean up from ets (?)
end
