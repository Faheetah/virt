defmodule Virt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Virt.Repo,
      # Start the Telemetry supervisor
      VirtWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Virt.PubSub},
      # Start the Endpoint (http/https)
      VirtWeb.Endpoint,
      # Start a worker by calling: Virt.Worker.start_link(arg)
      # {Virt.Worker, arg}
      {Task.Supervisor, name: Virt.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Virt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VirtWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
