defmodule EisWeb.GameRegistry do
  use GenServer
  @compile {:parse_transform, :ms_transform}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [],name: __MODULE__)
  end

  # use Porcess.monitor to receive down message
  # TODO: hand over :ets to supervisor when this crashes
  # TODO: have a clean up task, compare gproc table and ets table
  # eliminate all entries that are not in gproc table.
  # TODO: refactor casts into call + implement retrying (?)


  def start_game(user_id) when is_binary(user_id) do
    game_id = GenServer.call(__MODULE__, {:start_game, user_id})
    GenServer.cast(__MODULE__, {:monitor_game, game_id})
    game_id
  end

  @spec start_game(pid(), any()) :: String.t()
  def start_game(pid, user_id) when is_pid(pid) and is_binary(user_id) do
    game_id = GenServer.call(__MODULE__, {:start_game, user_id})
    GenServer.cast(__MODULE__, {:monitor_game, game_id})
    game_id
  end

  def monitor_game(game_id) do
    GenServer.cast(__MODULE__, {:monitor_game, game_id})
  end
  def monitor_game(pid, game_id) when is_pid(pid) do
    GenServer.cast(pid, {:monitor_game, game_id})
  end

  def stop_game(game_id) do
    GenServer.cast(__MODULE__, {:stop_game, game_id})
  end
  def stop_game(pid, game_id) when is_pid(pid) do
    GenServer.cast(__MODULE__, {:stop_game, game_id})
  end

  def get_game_id_with(user_id) do
    GenServer.call(__MODULE__, {:get_game_id, user_id})
  end

  ### Server

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:start_game, user_id}, _from, _) do
    {:ok, game_id} = add_game(user_id)
    try do
      DynamicSupervisor.start_child(EisWeb.GameSupervisor, {EisWeb.GameServer, game_id})
    rescue
      _ -> {:reply, {:error, game_id}, {:error, game_id}}
    end
    {:reply, game_id, game_id}
  end

  def handle_call({:get_game_id, user_id}, _from, _) do
    case get_game_id(user_id) do
      {:ok, game_id} -> {:reply, game_id, game_id}
      {:error, _} -> {:reply, nil, nil}
    end
  end

  def handle_call({:get_game, game_id}, _from, state) do
    case get_game_state(game_id) do
      {:ok, game_state} -> {:reply, game_state, game_state}
      _ -> {:noreply, state}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # with {:ok, game_id} <- get_game_id(pid) do
    #   EisWeb.GameBackup.delete(game_id)
    # end
    {:noreply, state}
  end

  def handle_info({:"ETS-TRANSFER", table_name, pid, :giveaway}, state) do
    # pid_string = :erlang.pid_to_list(pid)
    # IO.puts "#{pid_string} is dead. Bye!"
    # give_away_ets(table_name, :giveaway)
    # IO.puts "giving table back!"
    {:noreply, state}
  end

  def handle_cast({:stop_game, game_id}, _) do
    case get_pid(game_id) do
      :undefined -> {:noreply, game_id}
      pid -> DynamicSupervisor.terminate_child(EisWeb.GameSupervisor, pid)
           delete_users_in_game(game_id)
           {:noreply, game_id}
    end
  end

  def handle_cast({:monitor_game, game_id}, state) do
    Process.monitor(get_pid(game_id))
    {:noreply, state}
  end

  def handle_cast({:backup_game, game_id, state}, _) do
    backup_game_state(game_id, state)
    {:noreply, state}
  end

  def handle_cast({:delete_game, game_id, _}, state) do
    delete_game_state(game_id)
    {:noreply, state}
  end

  ### implmentation - user to game table

  defp get_pid(game_id) do
    :gproc.where({:n, :l, {:game, game_id}})
  end

  defp add_game(user_id) do
    game_id = UUID.uuid4()
    :ets.insert(:user_to_game, {user_id, game_id})
    {:ok, game_id}
  end

  defp check_and_user_to_game(user_id, game_id) do
    case :ets.match(:user_to_game, {:"$1", game_id}) do
      [ _ ] -> add_user_to_game(user_id, game_id)
      [] -> {:error, "no game with #{game_id}"}
      end
  end

  defp add_user_to_game(user_id, game_id) do
    :ets.insert(:user_to_game, {user_id, game_id})
    {:ok, game_id}
  end

  defp get_users(game_id) do
    case :ets.match(:user_to_game, {:"$1", game_id}) do
      [] -> {:error, "no users with #{game_id}"}
      users -> {:ok, List.flatten(users)}
    end
  end

  defp delete_users_in_game(game_id) do
    {:ok, users} = get_users(game_id)
    users
    |> Enum.each(fn user_id -> :ets.delete(:user_to_game, user_id) end)
  end

  defp get_game_id(user_id) when is_binary(user_id) do
    case :ets.match(:user_to_game, {user_id, :"$1"}) do
      [] -> {:error, "no game associated with #{user_id}"}
      [[game_id]| _] -> {:ok, game_id}
    end
  end

  defp get_game_id(pid) when is_pid(pid) do
    matcher = :ets.fun2ms(fn {key, pid, _} when pid == pid -> key end)
    case :gproc.select(matcher) do
      [{:n, :l, {:game, game_id}}| _]  -> {:ok, game_id}
      _ -> {:error, "no game found with pid"}
    end
  end

  ### implmentation - game state back up

  defp delete_game_state(game_id) do
    :ets.delete(:game_states, game_id)
  end

  defp backup_game_state(game_id, state) do
    :ets.insert(:game_states, {game_id, state})
    {:ok, game_id}
  end

  defp get_game_state(game_id) do
    case :ets.match(:game_states, {game_id, :"$1"}) do
      [] -> {:error, "no game associated with #{game_id}"}
      [state| _] -> {:ok, state}
    end
  end
end
