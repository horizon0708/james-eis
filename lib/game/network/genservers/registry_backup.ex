defmodule EisWeb.RegistryBackup do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [],name: __MODULE__)
  end

  #https://github.com/niahoo/blanket/blob/master/lib/blanket/heir.ex
  # https://github.com/DeadZen/etsgive/blob/master/src/etsgive_mgr.erl#L118

  def init(_) do
    init_table(:user_to_game)
    {:ok, %{}}
  end

  def handle_info({:"ETS-TRANSFER", table_name, pid, :giveaway}, state) do
    pid_string = :erlang.pid_to_list(pid)
    IO.puts "#{pid_string} is dead. Bye!"
    give_away_ets(table_name, :giveaway)
    IO.puts "giving table back!"
    {:noreply, state}
  end

  defp wait_to_get_pid() do
    case Process.whereis(EisWeb.GameRegistry) do
      :nil ->
        :timer.sleep(1)
        wait_to_get_pid()
      pid -> pid
    end
  end

  defp init_table(table_name) do
    if :ets.whereis(table_name) == :undefined do
      :ets.new(table_name, [:set, :protected, :named_table,{:heir, self(), :giveaway}])
      # :ets.new(table_name, [:set, :protected, :named_table])
    end
    give_away_ets(table_name, :giveaway)
  end

  defp give_away_ets(table_name, data) do
    pid = wait_to_get_pid()
    :ets.give_away(table_name, pid, data)
  end
end
