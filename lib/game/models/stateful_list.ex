defmodule StatefulList do
  @moduledoc """

  """

  @type t(something) ::%__MODULE__{
    internal_list: something,
    current_index: number,
    previous_index: number,
  }

  @enforce_keys [:internal_list]
  defstruct internal_list: [],
    current_index: 0,
    previous_index: 0

  @spec current(StatefulList.t) :: any | nil
  def current(%StatefulList{} = stateful_list) do
    Enum.at(stateful_list.internal_list, stateful_list.current_index)
  end

  def at(%StatefulList{} = stateful_list, index) do
    Enum.at(stateful_list.internal_list, index)
  end

  @moduledoc """
  Loops around to the start when at the end of the list
  """
  @spec next(StatefulList.t()) :: StatefulList.t()
  def next(%StatefulList{} = stateful_list) do
    next_number = if stateful_list.current_index + 1 > length(stateful_list.internal_list) - 1 do
      0
    else
      stateful_list.current_index + 1
    end
    %{stateful_list | previous_index: stateful_list.current_index, current_index: next_number}
  end

  @doc """
  Jump to a state. If index is larger than the length, it goes to the end of the list
  """
  @spec jump(StatefulList.t(), number) :: StatefulList.t()
  def jump(%StatefulList{} = stateful_list, jump_index) do
    next_number = if  jump_index > length(stateful_list.internal_list) - 1 do
      length(stateful_list.internal_list) - 1
    else
      jump_index
    end
    %{stateful_list | previous_index: stateful_list.current_index, current_index: next_number}
  end

  @doc """
  Go to previous state
  """
  @spec previous(StatefulList.t()) :: StatefulList.t()
  def previous(%StatefulList{} = stateful_list) do
    %{stateful_list |  current_index: stateful_list.previous_index, previous_index: stateful_list.current_index}
  end
end
