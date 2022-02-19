defmodule VirtWeb.HostLive.Show do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Hosts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    host = get_host(id)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:host, host)
      |> assign(:libvirt_stats, Virt.Libvirt.Hosts.get_libvirt_stats(host))
    }
  end

  @impl true
  def handle_event("synchronize", %{"pool-id" => pool_id, "id" => id, "key" => key}, socket) do
    {:ok, _} = Virt.Libvirt.Volumes.synchronize_libvirt_volume(pool_id, %{"name" => id, "key" => key})

    {:noreply, socket}
  end

  # this is inefficient as it reloads all hosts, need to track volumes by ID
  def handle_event("delete_volume", %{"id" => id, "host-id" => host_id}, socket) do
    volume = Virt.Libvirt.Volumes.get_volume!(id)
    {:ok, _} = Virt.Libvirt.Volumes.delete_volume(volume)

    {:noreply, assign(socket, :host, get_host(host_id))}
  end

  defp get_host(id) do
    Hosts.get_host!(id)
    |> Virt.Repo.preload([:domains, pools: [:volumes], host_distributions: [:volume, :distribution]])
  end

  defp page_title(:show), do: "Show Host"
  defp page_title(:edit), do: "Edit Host"
end
