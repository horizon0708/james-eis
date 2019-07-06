defmodule EisWeb.ComponentView do

  defmacro __using__(opts \\ []) do
    quote do
      use Phoenix.View,
        root: unquote("lib/eis_web/live_components" <> get_group(opts)),
        namespace: EisWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import EisWeb.ErrorHelpers
      import EisWeb.Gettext
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
      alias EisWeb.Router.Helpers, as: Routes

      def component_render(socket, module, user_id) when is_atom(module) do
        module = Atom.to_string(module) <> "Component"
        module = Module.concat("EisWeb", module)
        live_render(socket, module, [session: %{user_id: user_id}])
      end
    end
  end

  def get_group(keywords) do
    case Keyword.get(keywords, :group) do
      nil -> ""
      name -> "/" <> name
    end
  end
end
