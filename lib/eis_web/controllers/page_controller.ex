defmodule EisWeb.PageController do
  use EisWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)
    LiveView.Controller.live_render(conn, EisWeb.JoinView, session: %{user_id: user_id})
  end
end
