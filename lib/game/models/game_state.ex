defmodule Game.State do
   @type t() ::%__MODULE__{
      id: String.t,
      config: Game.Config.t,
      game_status: :ready | :playing | :paused | {:ended, String.t},
      turn_status: :ready | :playing | :paused | :ended,
      turn: number,
      players: Game.Players.t(Game.Player.t),
      categories: StatefulList.t(Game.Category.t),
      board: list
   }


   @enforce_keys [:id]
   defstruct players: %Game.Players{}, # {id, name, score, color}
            id: nil,
            config: %Game.Config{},
            turn_status: :ready, # ready, game, end,
            game_status: :ready,
            turn: 0,
            categories: %StatefulList{internal_list: []},
            list: [],
            board: []



   # Before Game starts
   @spec start_lobby(Game.Config.t, binary) :: Game.State.t()
   def start_lobby(%Game.Config{}= config, game_id) when is_binary(game_id) do
      game_state = %Game.State{id: game_id}
      %{game_state | config: config}
   end

   @doc """
   returns the same game object when the limit of players (4) is reached
   """
   @spec add_player(Game.State.t(), binary, binary) :: Game.State.t()
   def add_player(%Game.State{game_status: :ready} = game_state, player_id)
   when is_binary(player_id) do
      IO.inspect(game_state.players)
      IO.inspect(player_id)
      players = Game.Players.add_player(game_state.players, player_id)
      %{game_state | players: players}
   end

   def add_player(%Game.State{} = game_state, _ ,_) do
      game_state
   end

   def name_exists?(%Game.State{players: players}, name) do
      Game.Players.name_exists?(players, name)
   end

   def get_players(%Game.State{players: players}) do
      Game.Players.get_players_name(players)
   end

   def change_name(%Game.State{players: players} = game_state, user_id, name) do
      %{game_state | players: Game.Players.set_name(players, user_id, name)}
   end


   @doc """
   returns the same game object on if game status is not ready
   """
   def start_game(%Game.State{game_status: :ready} = game_state) do
      Game.State.update_game_status(game_state, :ready)
   end

   def start_game(%Game.State{} = game_state) do
      game_state
   end


   # In Game


   def next_turn(%Game.State{} = game_state) do
      players = Game.Players.next(game_state.players)
      %{game_state | players: players, turn: game_state.turn + 1}
   end

   def increment_player_score(%Game.State{} = game_state, player_id, score_to_add \\ 1) do
      players = Game.Players.increment_score(game_state.players, player_id, score_to_add)
      %{game_state | players: players}
   end

   def update_game_status(%Game.State{} = game_state, status) do
      %{game_state | game_status: status}
   end

   def update_turn_status(%Game.State{} = game_state, status)
   when status in [:ready, :playing, :paused, :ended] do
      %{game_state | turn_status: status}
   end

   @spec get_current_category(Game.State.t()) :: Game.Category.t
   def get_current_category(%Game.State{} = game_state) do
      player = get_current_player(game_state)
      category_index = Enum.at(game_state.board, player.score)
      StatefulList.at(game_state.categories, category_index)
   end

   @spec get_current_player(Game.State.t()) :: Game.Player.t
   def get_current_player(%Game.State{} = game_state) do
      Game.Players.current(game_state.players)
   end
end
