defmodule VirtWeb.HostLive.Show do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Pools
  alias Virt.Libvirt.Pools.Pool

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
  def handle_event("synchronize_volume", %{"host-id" => host_id, "pool-name" => pool_name, "id" => id, "key" => key}, socket) do
    pool = Pools.get_pool_by_name!(host_id, pool_name)
    {:ok, _} = Virt.Libvirt.Volumes.synchronize_libvirt_volume(pool.id, %{"name" => id, "key" => key})

    {:noreply, socket}
  end

  @impl true
  def handle_event("synchronize_pool", pool, socket) do
    {:ok, _} =
      pool
      # these attributes cannot be derived from libvirt, will need to parse XML to import
      |> Map.merge(%{"host_id" => pool["host-id"], "path" => "/dev/null", "type" => "dir"})
      |> then(&Pool.changeset(%Pool{}, &1))
      |> Virt.Repo.insert()

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_libvirt_volume", _volume, socket) do
    {:noreply, socket}
  end


  @impl true
  def handle_event("delete_libvirt_pool", %{"id" => id, "name" => name, "host-id" => host_id}, socket) do
    host = Hosts.get_host!(host_id)
    {:ok, connection} = Libvirt.connect(host.connection_string)
    Libvirt.storage_pool_destroy(connection, %{"pool" => %{"name" => name, "uuid" => id}})
    {:ok, nil} = Libvirt.storage_pool_undefine(connection, %{"pool" => %{"name" => name, "uuid" => id}})

    {:noreply, socket}
  end


  # this is inefficient as it reloads all hosts, need to track volumes by ID
  def handle_event("delete_volume", %{"id" => id, "host-id" => host_id}, socket) do
    volume = Virt.Libvirt.Volumes.get_volume!(id)
    {:ok, _} = Virt.Libvirt.Volumes.delete_volume(volume)

    {:noreply, assign(socket, :host, get_host(host_id))}
  end

  def handle_event("delete_pool", %{"id" => id, "host-id" => host_id}, socket) do
    pool = Virt.Libvirt.Pools.get_pool!(id)
    {:ok, _} = Virt.Libvirt.Pools.delete_pool(pool)

    {:noreply, assign(socket, :host, get_host(host_id))}
  end

  defp get_host(id) do
    Hosts.get_host!(id)
    |> Virt.Repo.preload([:domains, pools: [:volumes], host_distributions: [:volume, :distribution]])
  end

  defp page_title(:show), do: "Show Host"
  defp page_title(:new_pool), do: "New Pool"
  defp page_title(:edit), do: "Edit Host"
end
