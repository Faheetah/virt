defmodule VirtWeb.DomainLive.FormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Domains
  alias Virt.Libvirt.Distributions
  alias Virt.Network.Subnets
  alias Virt.Secrets.AccessKeys

  @vcpu_options ~w[1 2 4 8 16]
  @memory_options ~w[512 1024 2048 4096 8192 16384]
  @disk_options [10, 20, 40, 80, 120, 250, 500]

  @impl true
  def update(%{domain: domain} = assigns, socket) do
    changeset = Domains.change_domain(domain)
    distributions = Distributions.list_distributions()
    subnets = Subnets.list_subnets()
    subnet_options = Enum.map(subnets, fn s -> {s.network, s.id} end)
    access_keys = AccessKeys.list_access_keys()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:distributions, distributions)
      |> assign(:vcpu_options, @vcpu_options)
      |> assign(:memory_options, @memory_options)
      |> assign(:disk_options, @disk_options)
      |> assign(:subnets, subnet_options)
      |> assign(:access_keys, access_keys)
      |> assign(:selected_keys, [])
    }
  end

  @impl true
  def handle_event("validate", %{"domain" => domain_params}, socket) do
    changeset =
      socket.assigns.domain
      |> Domains.change_domain(domain_params)
      |> Map.put(:action, :validate)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:selected_keys, domain_params["access_keys"] || [])
    }
  end

  @impl true
  def handle_event("save", %{"domain" => domain_params}, socket) do
    save_domain(socket, socket.assigns.action, domain_params)
  end

  defp save_domain(socket, :new, domain_params) do
    case Domains.create_domain(domain_params) do
      {:ok, _domain} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Domain request processed")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          assign(socket, changeset: Map.put(changeset, :action, :validate))
        }

      _ ->
        {
          :noreply,
          socket
          |> put_flash(:error, "Domain failed to provision")
          |> push_redirect(to: socket.assigns.return_to)
        }
    end
  end
end
