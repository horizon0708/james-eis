defmodule Game.Network.Server do
  @behaviour Game.Network.ServerBehaviour
  use GenServer
  import Game.Network.Helper
  import Game.Logic.OnGameUpdate

  def start_link(user_id) do
    game_id= Game.Network.Registry.get_game_id(user_id)
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(game_id))
  end

  # TODO: LOGGING?
  @spec get_game(binary()) :: Game.State.t | nil
  def get_game(game_id) when is_binary(game_id) do
    try do
      GenServer.call(via_tuple(game_id), {:get})
    catch
      :exit, _ -> nil
    end
  end
  def get_game(_game_id) do
    nil
  end

  @spec get_game(binary(), number()) :: Game.State.t | nil
  def get_game(game_id, index) when is_binary(game_id) and is_number(index) do
    try do
      GenServer.call(via_tuple(game_id), {:get_at, index})
    catch
      :exit, _ -> nil
    end
  end


  @spec update_game(binary(), Game.Command.t) :: :error | :ok
  def update_game(game_id, %Game.Command{}= command) do
    GenServer.call(via_tuple(game_id), {:update, command})
  end

  # -- SERVER --

  def init(user_id) do
    {:ok, initialize_game_store(user_id)}
    # case retry_get(game_id) do
    #   nil ->
    #     {:ok, initialize_game_store(game_id)}
    #   game_store ->
    #     IO.puts "reloading game store"
    #     {:ok, game_store}
    # end
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

  defp initialize_game_store(user_id) do
    game_store = %Game.Network.Store{}
    IO.puts user_id
    game_id= Game.Network.Registry.get_game_id(user_id)
    # game_id= Game.Network.Registry.start_game(user_id)

    command_1= %Game.Command{
      sender: "System",
      module: Game.Logic,
      function: :start_lobby,
      args: [%Game.Config{}, game_id]
    }
    command_2 = %Game.Command{
      sender: "System",
      module: Game.Logic,
      function: :add_player,
      args: [user_id]
    }
    commands = [ command_2, command_1 ]
    latest_state = compute_latest_game_state(commands)
    %{game_store | latest_state: latest_state, commands: commands}
  end


  @doc """
  0 as beginning game state
  """
  defp compute_latest_game_state(commands) do
    List.foldr(commands, %Game.State{id: nil}, fn command, state -> apply(command.module, command.function, [state | [command.args]]) end)
  end

  @doc """
  TODO: should write a test for this
  """
  defp compute_game_state_at(list, index, curr_state \\ %Game.State{id: nil} )when index > -1 and is_list(list) do
    {command, list} = List.pop_at(list, 0)
    curr_state = case command do
      command -> apply(command.module, command.function, [curr_state| [command.args]])
      nil -> curr_state
    end
    index = index - 1

    if index < 0 do
      curr_state
    else
      compute_game_state_at(list, index, curr_state)
    end
  end


  def handle_call({:update, %Game.Command{} = command},_from, game_store) do
    commands = [command | game_store.commands ]
    next_state = apply(command.module, command.function, [ game_store.latest_state | [command.args]])

    commands = on_after_update(commands, next_state)
    latest_state = compute_latest_game_state(commands)

    updated = %{game_store | commands: commands, latest_state: latest_state}
    game_id = latest_state.id
    if game_id != nil do
      # EisWeb.GameBackup.update(game_id, updated)
      broadcast(game_id, latest_state)
    end
    {:reply, {:ok, updated}, updated}
  end

  @spec on_after_update(Game.State.t, Game.State.t) :: list(Game.Command.t)
  def on_after_update(commands, state) do
    commands
    |>player_wins_on_score(state)
  end

  def handle_call({:get}, _from, game_store) do
    {:reply, game_store.latest_state, game_store}
  end

  def handle_call({:get_at, index}, _from, game_store) do
    max = length(game_store.commands)-1
    min = 0
    index = cond do
      index > max -> max
      index < min -> min
      true -> index
    end
    state = Enum.reverse(game_store.commands)
    |> compute_game_state_at(index)
    {:reply, state, game_store}
  end

  defp broadcast(game_id, new_state) do
    key = {:p, :l, {:broadcast, game_id}}
    data = {:state_updated, new_state}
    :gproc.send(key, data)
    :ok
  end
end
