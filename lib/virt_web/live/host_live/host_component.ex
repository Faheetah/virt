defmodule VirtWeb.HostLive.HostComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Hosts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    host =
      Hosts.get_host!(id)
      |> Virt.Repo.preload([:pools, :domains, host_distributions: [:volume, :distribution]])

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:host, host)
    }
  end

  defp page_title(:show), do: "Show Host"
  defp page_title(:edit), do: "Edit Host"
end
