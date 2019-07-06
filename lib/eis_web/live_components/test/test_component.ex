defmodule EisWeb.TestComponent do
  use Phoenix.LiveView
  use EisWeb.ComponentBase


  def assigns(%{user_id: user_id}) do
    %{hi: user_id}
  end

  def handle_event("validate", %{"name" => params}, socket) do

    changeset =
      %Lobby.Name{}
      |> Lobby.Name.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
    end

    def handle_event("join",  %{"name" => %{"name" => name}}, socket = %{assigns: %{user_id: user_id}}) do
      case Game.Network.Api.change_player_name(user_id, name) do
        {:ok, _} -> socket = redirect(socket, to: "/game")
              {:stop, socket}
        :error -> socket = put_flash(socket, :error, "error joining the game")
              {:stop, socket}
      end
    end
end
