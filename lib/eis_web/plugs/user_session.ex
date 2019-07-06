defmodule Plug.UserSession do
  def init([]), do: []

  @behaviour Plug

  def call(%Plug.Conn{} = conn, []) do
    assign_session_id_if_nil(conn)
  end

  defp assign_session_id_if_nil(conn) do
    user_id = Plug.Conn.get_session(conn, :user_id)
    case user_id do
      nil -> Plug.Conn.put_session(conn, :user_id, UUID.uuid1)
      _ -> conn
    end
  end
end
