defmodule VirtWeb.DomainLive.Show do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Domains

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    domain =
      Domains.get_domain!(id)
      |> Virt.Repo.preload([domain_disks: [:volume], domain_interfaces: [:ip_address]])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:domain, domain)}
  end

  defp page_title(:show), do: "Show Domain"
  defp page_title(:edit), do: "Edit Domain"
end
