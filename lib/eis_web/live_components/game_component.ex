defmodule EisWeb.GameComponent do

  defmacro __using__(opts \\ []) do
    %{module: module} = __CALLER__
    quote do
      use Phoenix.LiveView

      def render(user_id) when is_binary(user_id) do
        game_state = Game.Network.Api.get_current_state(user_id)

        assigns = %{user_id: user_id}
        |> Map.merge(assigns(game_state))

        unquote(get_component_name(module, opts)).render(unquote(get_template_name(module)), assigns)
      end

      def render(assigns) do
        # game_state = Game.Network.Api.get_current_state(user_id)
        # assigns = Map.put(assigns(%{game_state: game_state}), :user_id, user_id)
        assigns = Map.merge(assigns(assigns), assigns)
        unquote(get_component_name(module, opts)).render(unquote(get_template_name(module)), assigns)
      end

      def mount(assigns= %{user_id: user_id}, socket) do
        with game_state when not is_nil(game_state) <- Game.Network.Api.get_current_state(user_id),
          true <- Game.Network.Registry.register_component(game_state.id) do
          initial_assigns = Map.put(assigns, :game_state, game_state)
          final_assigns = Map.merge(assigns(initial_assigns), initial_assigns)
          {:ok, assign(socket, final_assigns)}
        else
          _ -> redirect(socket, to: "/")
            {:noreply, assign(socket, assigns)}
        end
      end
      def mount(assigns, socket) do
        redirect(socket, to: "/")
        {:ok, assign(socket, assigns)}
      end

      def handle_info({:state_updated, game_state}, socket) do
        new_assigns = assigns(game_state)
        {:noreply, assign(socket, new_assigns)}
      end
    end
  end

  @spec get_component_name(binary, any) :: atom
  def get_component_name(module, opts \\[]) do
    # name = Phoenix.Template.module_to_template_root(module, @namespace, "Component")
    name = Phoenix.Naming.unsuffix(module, "Component")
    view_module_name = Module.concat([name <> "View"])
    contents = quote do
      use EisWeb.ComponentView,
        unquote(opts)
    end
    Module.create(view_module_name, contents, Macro.Env.location(__ENV__))

    view_module_name
  end

  def get_template_name(module) do
    name = Phoenix.Naming.resource_name(module, "Component")
    "#{name}.html"
  end
end
