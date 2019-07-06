defmodule Lobby.Name do
  import Ecto.Changeset

  defstruct [:name ]

  def changeset(lobby_name, user_id, params \\ %{}) do
    types = %{
      name: :string
    }

    {lobby_name, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:name])
    |> validate_length(:name, [{:min, 2}, {:max, 20}])
    |> validate_unique_name(user_id)
  end

  def validate_unique_name(changeset, user_id, options \\ []) do
    validate_change(changeset, :name, fn _, name ->
      case Game.Network.Api.player_name_exists?(user_id, name) do
        true -> [{:name, options[:message] || "duplicate name"}]
        false -> []
        _ -> [{:name, options[:message] || "the game you are trying to join no longer exists"}]
      end
    end)
  end
end
