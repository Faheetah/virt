defmodule VirtWeb.DomainLive.Index do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Domains
  alias Virt.Libvirt.Domains.Domain

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "domains")
    end

    {:ok, assign(socket, :domains, list_domains())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    domain = Domains.get_domain!(id)
    socket
    |> assign(:page_title, "Edit #{domain.name}")
    |> assign(:domain, domain)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Domain")
    |> assign(:domain, %Domain{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:domain, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    domain = Domains.get_domain!(id)
    {:ok, _} = Domains.delete_domain(domain)

    {:noreply, assign(socket, :domains, list_domains())}
  end

  @impl true
  def handle_info({:domain_deleted, domain}, socket) do
    {
      :noreply,
      socket
      |> clear_flash()
      |> put_flash(:error, "Domain #{domain.id} failed to provision")
      |> assign(domains: list_domains())
    }
  end

  @impl true
  def handle_info({:domain_provisioned, domain}, socket) do
    {:noreply, update(socket, :domains, fn _ -> [domain] end)}
  end

  defp list_domains do
    Domains.list_domains()
    |> Virt.Repo.preload([:domain_interfaces, domain_disks: [volume: [:host_distribution]]])
  end
end
