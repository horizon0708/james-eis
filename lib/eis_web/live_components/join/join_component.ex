defmodule EisWeb.JoinComponent do
  use EisWeb.ComponentBase

  def assigns(_assigns)do
    default_game_id = %Lobby.Code{
      game_id: "",
    }
    %{changeset: Lobby.Code.changeset(default_game_id)}
  end

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
end
