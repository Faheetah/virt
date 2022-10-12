defmodule VirtWeb.SubnetLive.Show do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Network.Subnets
  alias Virt.Network.IpAddresses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    subnet =
      Subnets.get_subnet!(id)
      |> Virt.Repo.preload([ip_addresses: [domain_interface: [:domain]]])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:subnet, subnet)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, _socket) do
    ip = IpAddresses.get_ip_address!(id)
    {:ok, _} = IpAddresses.delete_ip_address(ip)
  end

  defp page_title(:show), do: "Show Subnet"
  defp page_title(:edit), do: "Edit Subnet"
end
