defmodule Game.Command do
  @type t() ::%__MODULE__{
    module: atom,
    function: atom,
    args: list,
    sender: String.t | atom
  }

  @enforce_keys [:module, :function, :args, :sender]

  defstruct [:module, :function, :args, :sender]

  def build(function_name, args \\ [], sender \\ "System",module \\ Game.Logic)
  when is_list(args)
  and is_atom(function_name)
  and is_binary(sender)
  and is_atom(module) do
    %Game.Command{
      sender: sender,
      module: module,
      function: function_name,
      args: args
    }
  end
end
