defmodule EisWeb.JoinLegacyView do
  use Phoenix.LiveView
  alias EisWeb.Router.Helpers, as: Routes
  def render(assigns) do
    EisWeb.LiveView.render("join.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    default_game_id = %Lobby.Code{
      game_id: "",
    }

    {:ok, assign(socket, %{changeset: Lobby.Code.changeset(default_game_id), user_id: user_id})}
  end


 # pub sub framework. need to broadcast from GenServer
 # how to persist user? https://elixirforum.com/t/pass-in-session-data-to-a-live-view-when-instigated-via-a-live-route/21565/2
 # key value store maps - cookie to pid (?)

 def handle_event("validate", %{"code" => params}, socket) do

  changeset =
    %Lobby.Code{}
    |> Lobby.Code.changeset(params)
    |> Map.put(:action, :insert)

  {:noreply, assign(socket, changeset: changeset, game_id: "asdf")}
  end

  def handle_event("join",  %{"code" => %{"game_id" => game_id}}, socket = %{assigns: %{user_id: user_id}}) do
    case Game.Network.Api.add_user_to_game(user_id, game_id) do
      :ok -> socket = redirect(socket, to: "/setname")
            {:stop, socket}
      :error -> socket = put_flash(socket, :error, "#{game_id} could not be found")
            {:stop, socket}
    end
  end

  def enforce_length(string, length \\ 5) when is_binary(string) do
  if(String.length(string) > length) do
    String.slice(string, 0, length)
  else
    string
  end
  end
end
