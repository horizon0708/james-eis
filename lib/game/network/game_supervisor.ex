defmodule Game.Network.Supervisor do
  use Supervisor
  import Game.Network.Helper

  @spec start_link(String.t) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(user_id) do
    game_id = Game.Network.Registry.start_game(user_id)
    Supervisor.start_link(__MODULE__, user_id, name: get_supervisor_id(game_id))
  end

  def init(user_id) do
    children = [
      {Game.Network.Server, user_id}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
