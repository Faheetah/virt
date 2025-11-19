defmodule Virt.Libvirt.Hosts do
  @moduledoc """
  The Libvirt.Hosts context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Libvirt.Hosts.{Host,HostDistribution}

  @doc """
  Returns the list of hosts.
  """
  def list_hosts do
    Repo.all(Host)
  end

  @doc """
  Gets a single host.

  Raises `Ecto.NoResultsError` if the Host does not exist.
  """
  def get_host!(id), do: Repo.get!(Host, id)

  @doc """
  Gets a host by name.
  """
  def get_host_by_name!(name) do
    Repo.get_by(Host, name: name)
  end

  @doc """
  Creates a host.
  """
  def create_host(attrs \\ %{}) do
    %Host{}
    |> Host.changeset(attrs)
    |> Repo.insert()
    |> tap(fn {:ok, host} -> provision_host(host) end)
  end

  def create_host!(attrs \\ %{}) do
    host =
      %Host{}
      |> Host.changeset(attrs)
      |> Repo.insert()

    case host do
      {:ok, host} -> provision_host(host)
      {:error, _} ->
        get_host_by_name!(attrs["name"])
        |> provision_host
    end
  end

  @doc """
  Updates a host.
  """
  def update_host(%Host{} = host, attrs) do
    host
    |> Host.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a host.

  WARNING: Deleting a host orphans all assets on the host. This is irreversible.
  """
  def delete_host(%Host{} = host) do
    Repo.delete(host)
  end

  @doc """
  Resets a host.
  WARNING: This will fully reset a host and all associated records.
  """
  def reset_host(%Host{} = host) do
    {:ok, conn} = Libvirt.connect(host.connection_string)
    args = %{"need_results" => 1, "flags" => 0}

    Libvirt.connect_list_all_domains(conn, args)
    |> then(&elem(&1, 1))
    |> Map.get("domains")
    |> Enum.each(&Libvirt.domain_destroy(conn, %{"dom" => &1}))

    Libvirt.connect_list_all_storage_pools(conn, args)
    |> then(&elem(&1, 1))
    |> Map.get("pools")
    |> Enum.each(fn pool ->
      Libvirt.storage_pool_list_all_volumes(conn, Map.put(args, "pool", pool))
      |> then(&elem(&1, 1))
      |> Map.get("vols")
      |> Enum.each(&Libvirt.storage_vol_delete(conn, %{"vol" => &1, "flags" => 0}))

      Libvirt.storage_pool_destroy(conn, %{"pool" => pool})
      Libvirt.storage_pool_undefine(conn, %{"pool" => pool})
    end)

    delete_host(host)
    Repo.insert(host)
  end

  def provision_host(%Host{} = host) do
    Virt.Libvirt.Pools.create_pool(%{name: "base_images", path: "/tmp/pool/base", type: "dir", host_id: host.id})
    Virt.Libvirt.Pools.create_pool(%{name: "customer_images", path: "/tmp/pool/customer", type: "dir", host_id: host.id})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking host changes.
  """
  def change_host(%Host{} = host, attrs \\ %{}) do
    Host.changeset(host, attrs)
  end

  # needs to also delete from host
  def delete_host_distribution(host, distribution) do
    Repo.one!(from hd in HostDistribution, where: [host_id: ^host.id, distribution_id: ^distribution.id])
    |> Repo.delete()
  end

  def get_libvirt_stats(%Host{} = host) do
    {:ok, socket} = Libvirt.connect(host.connection_string)
    args = %{"need_results" => 1, "flags" => 0}
    {:ok, %{"domains" => domains}} = Libvirt.connect_list_all_domains(socket, args)
    {:ok, %{"ifaces" => interfaces}} = Libvirt.connect_list_all_interfaces(socket, args)
    {:ok, %{"nets" => networks}} = Libvirt.connect_list_all_networks(socket, args)
    {:ok, %{"pools" => pools}} = Libvirt.connect_list_all_storage_pools(socket, args)
    {:ok, node_info} = Libvirt.node_get_info(socket)
    {:ok, %{"freeMem" => free_mem}} = Libvirt.node_get_free_memory(socket)

    %{
      domains: domains,
      interfaces: interfaces,
      networks: networks,
      pools: Enum.map(pools, &get_libvirt_volumes(socket, &1)),
      node_info: node_info,
      free_mem: free_mem,
    }
  end

  defp get_libvirt_volumes(socket, pool) do
    args = %{
      "pool" => pool,
      "need_results" => 1,
      "flags" => 0
    }

    {:ok, %{"vols" => volumes}} = Libvirt.storage_pool_list_all_volumes(socket, args)
    {:ok, stats} = Libvirt.storage_pool_get_info(socket, %{"pool" => pool})

    pool
    |> Map.put(:volumes, volumes)
    |> Map.put(:stats, stats)
  end
end
