defmodule VirtWeb.SubnetLive.Show do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Network.Subnets

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

  defp page_title(:show), do: "Show Subnet"
  defp page_title(:edit), do: "Edit Subnet"
end
