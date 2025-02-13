defmodule Virt.Libvirt.Domains do
  @moduledoc """
  The Libvirt.Domains context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Virt.Repo

  alias Virt.Libvirt.Domains.Domain
  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Hosts.HostDistribution
  alias Virt.Libvirt.Pools
  alias Virt.Libvirt.Volumes
  alias Virt.Libvirt.Templates
  alias Virt.Network.IpAddresses
  alias Virt.Network.Subnets

  @doc """
  Returns the list of domains.
  """
  def list_domains do
    Repo.all(Domain)
  end

  @doc """
  Gets a single domain.

  Raises `Ecto.NoResultsError` if the Domain does not exist.
  """
  def get_domain!(id), do: Repo.get!(Domain, id)

  def get_domain_primary_ip(domain) do
    if domain.domain_interfaces do
      ip = Enum.find(domain.domain_interfaces, fn i -> i.bridge == "br0" end)
      if ip do
        ip.ip_address.address
      end
    end
  end

  @doc """
  Creates a domain.
  """

  def create_domain(attrs \\ %{}) do
    case reserve_domain(attrs) do
      {:ok, domain} ->
        Virt.Provision.run_job(Virt.Jobs.CreateDomain, domain)

      {:error, error} ->
        {
          :error,
          %Domain{}
          |> Domain.changeset(Map.put(attrs, "memory_bytes", get_int(attrs["memory_mb"]) * 1024 * 1024))
          |> Ecto.Changeset.add_error(:general, error)
        }
    end
  end

  def reserve_domain(attrs \\ %{}) do
    with {:ok, host} <- find_host(attrs),
         {:ok, subnet} <- Subnets.get_subnet(attrs["subnet_id"]),
         {:ok, address} <- Subnets.find_available_ip(subnet),
         {:ok, ip_address} <- IpAddresses.create_ip_address(%{
           "subnet_id" => attrs["subnet_id"],
           "address" => address
         })
    do
      attrs =
        attrs
        |> Map.put("domain_interfaces", [
          %{type: "bridge", mac: gen_mac(), bridge: "br0", ip_address_id: ip_address.id}
        ])
        |> Map.put("domain_disks", reserve_domain_disks(host, attrs))
        |> Map.put("memory_bytes", get_int(attrs["memory_mb"]) * 1024 * 1024)
        |> Map.put("domain_access_keys", Enum.map(attrs["access_keys"], fn key_id -> %{"access_key_id" => key_id} end))

      %Domain{}
      |> Domain.changeset(Map.put(attrs, "host_id", host.id))
      |> Repo.insert()
    end
  end

  def provision_domain(%Domain{} = domain) do
    domain = Repo.preload(domain, [:host, domain_disks: [:volume]])
    Enum.each(domain.domain_disks, fn disk ->
      {:ok, _} = provision_domain_disk(domain.host, disk)
    end)
    domain = get_domain!(domain.id)

    with {:ok, _} <- create_libvirt_domain(domain) do
      {
        :ok,
        Repo.preload(domain, [domain_interfaces: [:ip_address], domain_disks: [:volume]])
      }
    end
  end

  defp reserve_domain_disks(host, %{"primary_disk_size_mb" => primary_size, "distribution" => _}) do
    with {:ok, pool} <- Pools.get_pool_by_name(host.id, "customer_images"),
         {:ok, volume} <- Virt.Libvirt.Volumes.create_volume(%{type: "qcow2", capacity_bytes: get_int(primary_size)*1024*1024, pool_id: pool.id})
    do
      [%{device: "hda", volume_id: volume.id}]
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset.errors}
    end
  end

  def provision_domain_disk(host, disk) do
    disk = Repo.preload(disk, [:domain, volume: [:host_distribution]])

    with {:ok, host_distribution} <-
            get_host_distribution(host, disk.domain.distribution),
         {:ok, volume} <-
            Virt.Libvirt.Volumes.provision_volume(disk.volume, host_distribution.volume)
    do
      {:ok, %{disk | volume: volume}}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, error} -> {:error, "could not create domain disk: #{error}"}
      _ -> {:error, "could not create disk"}
    end
  end

  # this will be capacity assignment in the future, for now just throw it on the first host
  # this obviously won't stay this way long term
  def find_host(_) do
    case Hosts.list_hosts() do
      [] -> {:error, "No available hosts found"}
      host -> {:ok, hd(host)}
    end
  end

  defp create_libvirt_domain(domain) do
    domain = Repo.preload(domain, [:host, domain_interfaces: [:ip_address], domain_disks: [:volume]])
    xml = Templates.render_domain(domain)
    {:ok, socket} = Libvirt.connect(domain.host.connection_string)
    {:ok, %{"remote_nonnull_domain" => libvirt_domain}} = Libvirt.domain_define_xml(socket, %{"xml" => xml})
    Libvirt.domain_create(socket, %{"dom" => libvirt_domain})
    {:ok, libvirt_domain}
  end

  @doc """
  Updates a domain.
  """
  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a domain.
  """
  def delete_domain(%Domain{} = domain) do
    domain
    |> Repo.preload([domain_disks: [:volume]])
    |> Map.get(:domain_disks)
    |> Enum.each(fn disk -> Volumes.delete_volume(disk.volume) end)

    domain
    |> Repo.preload([domain_interfaces: [:ip_address]])
    |> Map.get(:domain_interfaces)
    |> Enum.reject(fn interface -> interface.ip_address == nil end)
    |> Enum.each(fn interface -> IpAddresses.delete_ip_address(interface.ip_address) end)

    with _ <- delete_libvirt_domain(domain),
         {:ok, domain} <- Repo.delete(domain)
    do
      Phoenix.PubSub.broadcast(Virt.PubSub, "domains", {:domain_deleted, domain})
      {:ok, domain}
    end
  end

  defp delete_libvirt_domain(domain) do
    with domain <- Repo.preload(domain, [:host]),
         {:ok, socket} <- Libvirt.connect(domain.host.connection_string),
         {:ok, nil} <- Libvirt.domain_destroy(socket, %{"dom" => %{"name" => domain.name, "uuid" => domain.id, "id" => -1}}), # don't think "id" is necessary
         {:ok, nil} <- Libvirt.domain_undefine(socket, %{"dom" => %{"name" => domain.name, "uuid" => domain.id, "id" => -1}}) # don't think "id" is necessary
    do
      :ok
    else
      {:error, packet} ->
        # also delete volume if storage pool does not exist
        if packet.payload =~ "VIR_ERR_NO_DOMAIN" do
          :ok
        else
          {:error, packet}
        end
      error -> {:error, error}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking domain changes.
  """
  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end

  def broadcast({:ok, domain}, event) do
    Phoenix.PubSub.broadcast(Virt.PubSub, "domains", {event, domain})
    {:ok, domain}
  end

  defp get_int(val), do: elem(Integer.parse(val), 0)

  defp gen_mac do
    suffix =
      <<:rand.uniform(255), :rand.uniform(255), :rand.uniform(255)>>
      |> Base.encode16(case: :lower)
      |> String.to_charlist()
      |> Enum.chunk_every(2)
      |> Enum.join(":")
    "b0:0b:1e:" <> suffix
  end

  defp get_host_distribution(_, nil), do: {:error, "distribution is nil"}
  defp get_host_distribution(host, distribution_key) do
    distribution = Virt.Libvirt.Distributions.get_distribution_by_key!(distribution_key)
    host_distribution =
      Virt.Repo.one(from hd in HostDistribution, where: [host_id: ^host.id, distribution_id: ^distribution.id])
      |> Virt.Repo.preload([volume: [:pool]])

    if host_distribution do
      {:ok, host_distribution}
    else
      {:error, "no distribution found"}
    end
  end

  def restart_domain(id) do
    domain =
      get_domain!(id)
      |> Virt.Repo.preload([:host])

    {:ok, socket} = Libvirt.connect(domain.host.connection_string)

    {:ok, %{"remote_nonnull_domain" => dom}} = Libvirt.domain_lookup_by_uuid(socket, %{"uuid" => id})
    Libvirt.domain_reboot(socket, %{"dom" => dom, "flags" => 0})
    update_domain(domain, %{"online" => true})
  end

  def shutdown_domain(id) do
    domain =
      get_domain!(id)
      |> Virt.Repo.preload([:host])

    {:ok, socket} = Libvirt.connect(domain.host.connection_string)

    {:ok, %{"remote_nonnull_domain" => dom}} = Libvirt.domain_lookup_by_uuid(socket, %{"uuid" => id})
    Libvirt.domain_shutdown(socket, %{"dom" => dom})
    update_domain(domain, %{"online" => false})
  end

  def start_domain(id) do
    domain =
      get_domain!(id)
      |> Virt.Repo.preload([:host])

    {:ok, socket} = Libvirt.connect(domain.host.connection_string)

    {:ok, %{"remote_nonnull_domain" => dom}} = Libvirt.domain_lookup_by_uuid(socket, %{"uuid" => id})
    Libvirt.domain_create(socket, %{"dom" => dom})
    update_domain(domain, %{"online" => true})
  end
end
