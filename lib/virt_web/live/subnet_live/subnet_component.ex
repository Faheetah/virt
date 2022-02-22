defmodule VirtWeb.SubnetLive.SubnetComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Network.Subnets

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    subnet =
      Subnets.get_subnet!(id)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:subnet, subnet)
    }
  end

  defp page_title(:show), do: "Show Subnet"
  defp page_title(:edit), do: "Edit Subnet"
end
