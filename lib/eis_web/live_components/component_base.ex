defmodule EisWeb.ComponentBase do
  @namespace EisWeb


  defmacro __using__(_opts \\ []) do
    %{module: module} = __CALLER__
    quote do
      use Phoenix.LiveView

      def render(user_id) when is_binary(user_id) do
        game_state = Game.Network.Api.get_current_state(user_id)

        assigns = %{user_id: user_id}
        |> Map.merge(assigns(game_state))

        unquote(get_component_name(module)).render(unquote(get_template_name(module)), assigns)
      end

      def render(assigns) do
        # game_state = Game.Network.Api.get_current_state(user_id)
        # assigns = Map.put(assigns(%{game_state: game_state}), :user_id, user_id)
        assigns = Map.merge(assigns(assigns), assigns)
        unquote(get_component_name(module)).render(unquote(get_template_name(module)), assigns)
      end

      def mount(assigns= %{user_id: user_id}, socket) do
        game_state = Game.Network.Api.get_current_state(user_id)
        assigns = Map.put(assigns, :game_state, game_state)
        assigns = Map.merge(assigns(assigns), assigns)
        {:ok, assign(socket, assigns)}
      end
      def mount(assigns, socket) do
        redirect(socket, to: "/")
        {:ok, assign(socket, assigns)}
      end


    end
  end

  def get_component_name(module) do
    # name = Phoenix.Template.module_to_template_root(module, @namespace, "Component")
    name = Phoenix.Naming.unsuffix(module, "Component")
    view_module_name = Module.concat([name <> "View"])
    contents = quote do
      use EisWeb.ComponentView
    end
    Module.create(view_module_name, contents, Macro.Env.location(__ENV__))

    view_module_name
  end

  def get_template_name(module) do
    name = Phoenix.Naming.resource_name(module, "Component")
    "#{name}.html"
  end
end
