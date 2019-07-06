defmodule Eis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
  import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      EisWeb.Endpoint,
      # Starts a worker by calling: Eis.Worker.start_link(arg)
      # {Eis.Worker, arg},

      {DynamicSupervisor, [name: :game_supervisor, strategy: :one_for_one, restart: :transient]},
      Game.Network.Registry
      # EisWeb.GameBackup,
      # EisWeb.GameRegistry,
      # EisWeb.RegistryBackup # back up must be after GameRegistry or the server will not start
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eis.Supervisor]


    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
