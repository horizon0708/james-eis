defmodule EisWeb.SetupLegacyView do
  use Phoenix.LiveView

  def render(assigns) do
    EisWeb.LiveView.render("setup.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    default_config=%Game.Config{
      host_name: "",
      turn_duration: 60,
      rounds_to_win: 30,
      max_skip: 3
    }

    {:ok, assign(socket, %{changeset: Game.Config.changeset(default_config), user_id: user_id})}
  end


 # pub sub framework. need to broadcast from GenServer
 # how to persist user? https://elixirforum.com/t/pass-in-session-data-to-a-live-view-when-instigated-via-a-live-route/21565/2
 # key value store maps - cookie to pid (?)

 @spec handle_event(<<_::64>>, map, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
 def handle_event("validate", %{"config" => params}, socket) do
  changeset =
    %Game.Config{}
    |> Game.Config.changeset(params)
    |> Map.put(:action, :insert)

  {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"config" => params}, socket) do
    changeset =
      %Game.Config{}
      |> Game.Config.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
    end
end
