defmodule EisWeb.GameButton do
  #TODO: rename to GameComponent add handle-info
  defmacro __using__({function, args}) when is_atom(function) and is_list(args) do

    event_name = Atom.to_string(function)

    quote do
      use Phoenix.LiveView

      def mount(%{user_id: user_id}, socket) do
        IO.puts "hi"
        starting_state = case EisWeb.GameRegistry.get_game_id_with(user_id) do
          nil -> "no_state"
          id -> EisWeb.GameServer.get(id)
        end
        {:ok, assign(socket, game_state: starting_state, user_id: user_id)}
      end

      def handle_event(unquote(event_name), _value, socket) do
        # do the deploy process
        try do
          user_id = socket.assigns.user_id
          game_id = EisWeb.GameRegistry.get_game_id_with(user_id)
          EisWeb.GameServer.update(game_id, EisWeb.GameLogic.wrap(unquote(function), unquote(args)))
        rescue
          _ -> nil
        end
        {:noreply, socket}
      end

      # def render() do
      #   live_render(@socket, __MODULE__, session: %{user_id: @user_id})
      # end
    end
  end
end
