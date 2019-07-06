defmodule EisWeb.DebugController do
  use EisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => game_id}) do
    with game_state when not is_nil(game_state) <- Game.Network.Api.get_game(game_id) do
      render(conn, "show.html", game_state: game_state)
    else
      _ -> conn
      |> put_flash("Info", "#{game_id} not found")
      |> redirect(to: "/debug")
    end
  end
end
