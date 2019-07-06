defmodule Game.Network.Registry do
  use GenServer

  @behaviour Game.Network.RegistryBehavior

  @moduledoc """
  Responsible for connecting user_id to game_id
  """

  @user_table :user_to_game
  @type game_id :: String.t
  @type user_id :: String.t

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [],name: __MODULE__)
  end

  def register_component(game_id) do
    :gproc.reg({:p, :l, {:broadcast, game_id}})
  end

  @spec start_game(user_id) :: game_id | nil
  def start_game(user_id) do
    GenServer.call(__MODULE__, {:start_game, user_id})
  end

  def add_user_to_game(user_id, game_id) do
    GenServer.call(__MODULE__, {:add_user, user_id, game_id})
  end

  @spec get_game_id(user_id) :: game_id | nil
  def get_game_id(user_id) do
    GenServer.call(__MODULE__, {:get_game_id, user_id})
  end

  @spec delete_users_from_table(game_id) :: :ok | :error
  def delete_users_from_table(game_id) do
    GenServer.call(__MODULE__, {:delete_users, game_id})
  end

  def init(_) do
    if :ets.whereis(@user_table) == :undefined do
      :ets.new(@user_table, [:set, :protected, :named_table])
      IO.warn "ETS started without back up"
    end
    {:ok, nil}
  end

  def handle_call({:start_game, user_id}, _from, _) do
    # game_id = UUID.uuid4
    game_id = "aaaaa"
    :ets.insert(@user_table, {user_id, game_id})
    {:reply, game_id, game_id}
  end

  def handle_call({:get_game_id, user_id}, _from, _) do
    case :ets.match(@user_table, {user_id, :"$1"}) do
      [] -> {:reply, nil, nil}
      [[game_id]| _] -> {:reply, game_id, nil}
    end
  end

  def handle_call({:add_user, user_id, game_id}, _from, _) do
    case :ets.match(:user_to_game, {:"$1", game_id}) do
      [] -> {:reply, {:error, "#{game_id} was not found"}, nil}
      _ -> :ets.insert(@user_table, {user_id, game_id})
        {:reply, :ok, nil}
      end
  end

  def handle_call({:delete_users, game_id}, _, _) do
    result = delete_users_in_game(game_id)
    {:reply, result, nil}
  end

  defp delete_users_in_game(game_id) do
    with {:ok, users} <- get_users(game_id) do
      Enum.each(users, fn user_id -> :ets.delete(@user_table, user_id) end)
      :ok
    else
      # TODO: log error
      {:error, msg} -> {:error, msg}
      _ -> raise "ets error"
    end
  end

  defp get_users(game_id) do
    case :ets.match(:user_to_game, {:"$1", game_id}) do
      [] -> {:error, "no users with #{game_id}"}
      users -> {:ok, List.flatten(users)}
    end
  end
end
