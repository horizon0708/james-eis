defmodule Lobby.Code do
  import Ecto.Changeset

  defstruct [:game_id]

  def changeset(id, params \\ %{}) do
    types = %{
      game_id: :string
    }

    {id, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:game_id])
    |> validate_length(:game_id, [{:is, 5}])
  end
end
