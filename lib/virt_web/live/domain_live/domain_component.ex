defmodule VirtWeb.DomainLive.DomainComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Domains

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    domain =
      Domains.get_domain!(id)
      |> Virt.Repo.preload([domain_interfaces: [:ip_address], domain_disks: [volume: [:host_distribution]]])

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:domain, domain)
    }
  end

  defp page_title(:show), do: "Show Domain"
  defp page_title(:edit), do: "Edit Domain"
end
