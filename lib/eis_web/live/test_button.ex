defmodule EisWeb.TestButton do
  use EisWeb.GameButton, {:change_name, ["Dok"]}

  def render(assigns) do
    inner = "aaa"
    test = ~L"<%= inner %>"
    ~L"""
    <div class="">
      <div>
        <button phx-click="change_name"><%= test %></button>
      </div>
    </div>
    """
  end
end
