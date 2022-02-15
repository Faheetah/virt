defmodule Virt.Libvirt.Domains do
  @moduledoc """
  The Libvirt.Domains context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Virt.Repo

  alias Virt.Libvirt.Domains.Domain
  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Pools
  alias Virt.Libvirt.Templates

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

  @doc """
  Creates a domain.
  """
  def create_domain(attrs \\ %{}) do
    host = find_host(attrs)

    attrs =
      attrs
      |> Map.put("domain_interfaces", [
        %{type: "user", mac: gen_mac(), ip: "169.254.0.1/24"},
        %{type: "bridge", mac: gen_mac(), bridge: "br0", ip: attrs["primary_ip_cidr"]}
      ])
      |> Map.put("domain_disks", create_domain_disks(host, attrs))
      |> Map.put("memory_bytes", get_int(attrs["memory_mb"]) * 1024 * 1024)

    changeset = Domain.changeset(%Domain{}, Map.put(attrs, "host_id", host.id))

    with {:ok, domain} <- Repo.insert(changeset),
         domain <- Repo.preload(domain, [:host, :domain_interfaces, domain_disks: [:volume]]),
         {:ok, _} <- create_libvirt_domain(domain),
         {:ok, domain} <- update_domain(domain, %{"created" => true})
    do
      {:ok, domain}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, error, %Domain{} = domain} ->
        Logger.error(error)
        delete_domain(domain)
        {:error, Ecto.Changeset.add_error(changeset, :distribution, error)}
    end
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

  defp get_host_distribution(host, distribution) do
    host_distribution =
      Virt.Libvirt.Hosts.HostDistribution
      |> Virt.Repo.one(where: [host_id: host.id, distribution: [name: distribution]])
      |> Virt.Repo.preload([volume: [:pool]])

    if host_distribution do
      {:ok, host_distribution}
    else
      {:error, "no distribution found"}
    end
  end

  defp create_domain_disks(host, %{"primary_disk_size_mb" => primary_size, "distribution" => distribution}) do
    with {:ok, host_distribution} <-
            get_host_distribution(host, distribution),
         {:ok, pool} <-
            Pools.get_pool_by_name(host.id, "customer_images"),
         {:ok, volume} <-
            Virt.Libvirt.Volumes.create_volume(
              %{type: "qcow2", capacity_bytes: get_int(primary_size)*1024*1024, pool_id: pool.id},
              host_distribution.volume)
    do
      [%{device: "hda", volume_id: volume.id}]
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, error} -> {:error, "could not create domain disk: #{error}"}
      _ -> {:error, "could not create disk"}
    end
  end

  # this will be capacity assignment in the future, for now just throw it on the first host
  # this obviously won't stay this way long term
  def find_host(_) do
    Hosts.list_hosts() |> hd
  end

  defp create_libvirt_domain(domain) do
    with xml <- Templates.render_domain(domain),
         {:ok, socket} <- Libvirt.connect(domain.host.connection_string),
         {:ok, %{"remote_nonnull_domain" => libvirt_domain}} <- Libvirt.domain_create_xml(socket, %{"xml_desc" => xml, "flags" => 0})
    do
      {:ok, libvirt_domain}
    else
      {:error, %Libvirt.RPC.Packet{payload: error}} ->
        {:error, error, domain}
      {:error, :econnrefused} ->
        {:error, "Could not connect to Libvirt host #{domain.host.connection_string}"}
      error -> {:error, error, domain}
    end
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
    with :ok <- delete_libvirt_domain(domain),
         {:ok, domain} <- Repo.delete(domain)
    do
      {:ok, domain}
    end
  end

  defp delete_libvirt_domain(domain) do
    with domain <- Repo.preload(domain, [:host]),
         {:ok, socket} <- Libvirt.connect(domain.host.connection_string),
         {:ok, nil} <- Libvirt.domain_destroy(socket, %{"dom" => %{"name" => domain.name, "uuid" => domain.id, "id" => -1}}) # don't think "id" is necessary
    do
      :ok
    else
      {:error, packet} ->
        # also delete volume if storage pool does not exist
        if packet.payload =~ "VIR_ERR_NO_DOMAIN" do
          Repo.delete(domain)
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
end
