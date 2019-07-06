defmodule Game.Config do
  import Ecto.Changeset

  @type t() ::%__MODULE__{
    host_id: String.t,
    host_name: String.t,
    turn_duration: number,
    rounds_to_win: number,
    max_skip: number,
    categories: list
  }

  defstruct [:host_id, :host_name, :turn_duration, :rounds_to_win, :max_skip, :categories]


  def changeset(config, params \\ %{}) do
    types =
      %{host_id: :string,
      host_name: :string,
      turn_duration: :integer,
      rounds_to_win: :integer,
      max_skip: :integer,
      categories: :integer
    }

    {config, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:host_name, :turn_duration, :rounds_to_win, :max_skip])
    |> validate_length(:host_name, [{:min, 2}, {:max, 18}])
    |> validate_inclusion(:turn_duration, 30..300)
    |> validate_inclusion(:rounds_to_win, 5..30)
    |> validate_inclusion(:max_skip, 0..100)
  end


end
