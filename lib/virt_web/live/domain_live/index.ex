defmodule VirtWeb.DomainLive.Index do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Domains
  alias Virt.Libvirt.Domains.Domain

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :domains, list_domains())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Domain")
    |> assign(:domain, Domains.get_domain!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Domain")
    |> assign(:domain, %Domain{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Domains")
    |> assign(:domain, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    domain = Domains.get_domain!(id)
    {:ok, _} = Domains.delete_domain(domain)

    {:noreply, assign(socket, :domains, list_domains())}
  end

  defp list_domains do
    Domains.list_domains()
  end
end
