defmodule Game.Network.Store do
  @moduledoc """

  """

  @type function_name :: atom
  @type args :: list

  @type t() :: %__MODULE__{
    latest_state: Game.State,
    commands: [{function_name, args}]
  }

  defstruct [:latest_state, :commands]
end
