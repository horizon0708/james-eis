defmodule Game.Word do
  @type t() ::%__MODULE__{
    id: String.t,
    value: String.t,
    limitation: String.t | nil
  }

  # change set on this?

  @enforce_keys [:id, :value]
  defstruct [:id, :value, :limitation]
end
