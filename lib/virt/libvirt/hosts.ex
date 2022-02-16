defmodule Virt.Libvirt.Hosts do
  @moduledoc """
  The Libvirt.Hosts context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Libvirt.Hosts.Host

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
  Returns an `%Ecto.Changeset{}` for tracking host changes.
  """
  def change_host(%Host{} = host, attrs \\ %{}) do
    Host.changeset(host, attrs)
  end

  def get_libvirt_stats(%Host{} = host) do
    {:ok, socket} = Libvirt.connect(host.connection_string)
    args = %{"need_results" => 1, "flags" => 0}
    {:ok, %{"domains" => domains}} = Libvirt.connect_list_all_domains(socket, args)
    {:ok, %{"ifaces" => interfaces}} = Libvirt.connect_list_all_interfaces(socket, args)
    {:ok, %{"nets" => networks}} = Libvirt.connect_list_all_networks(socket, args)
    {:ok, %{"pools" => pools}} = Libvirt.connect_list_all_storage_pools(socket, args)

    %{
      domains: domains,
      interfaces: interfaces,
      networks: networks,
      pools: Enum.map(pools, &get_libvirt_volumes(socket, &1))
    }
  end

  defp get_libvirt_volumes(socket, pool) do
    args = %{
      "pool" => pool,
      "need_results" => 1,
      "flags" => 0
    }

    {:ok, %{"vols" => volumes}} = Libvirt.storage_pool_list_all_volumes(socket, args)
    Map.put(pool, :volumes, volumes)
  end
end
