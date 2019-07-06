defmodule EisWeb.SetupComponent do
  use EisWeb.ComponentBase

  # lets change to handle assign.. this is confusing.
  def assigns(_) do
    default_config=%Game.Config{
      host_name: "",
      turn_duration: 60,
      rounds_to_win: 30,
      max_skip: 3
    }

    %{changeset: Game.Config.changeset(default_config)}
  end

  def handle_event("validate", %{"config" => params}, socket) do
    changeset =
      %Game.Config{}
      |> Game.Config.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"config" => params}, socket= %{assigns: %{user_id: user_id}}) do
    case Game.Network.Api.start_game(user_id) do
      nil -> {:noreply, assign(socket, %{})}
      _ -> {:stop, redirect(socket, to: "/game")}
    end

  end
end
