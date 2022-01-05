defmodule Virt.Network.IpAddresses do
  @moduledoc """
  The Network.IpAddresses context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Network.IpAddresses.IpAddress
  alias Virt.Network.Subnets

  @doc """
  Returns the list of ip_addresses.
  """
  def list_ip_addresses do
    Repo.all(IpAddress)
  end

  @doc """
  Gets a single ip_address.

  Raises `Ecto.NoResultsError` if the Ip address does not exist.
  """
  def get_ip_address!(id), do: Repo.get!(IpAddress, id)

  @doc """
  Creates a ip_address.
  """
  def create_ip_address(attrs \\ %{}) do
    changeset = IpAddress.changeset(%IpAddress{}, attrs)
    subnet = Subnets.get_subnet!(attrs["subnet_id"])
    if address_in_subnet(attrs["address"], subnet.network, subnet.netmask) do
      Repo.insert(changeset)
    else
      Ecto.Changeset.add_error(changeset, :address, "not in range", address: attrs["address"], network: subnet.network, netmask: subnet.netmask)
    end
  end

  def address_in_subnet(ip, network, netmask) do
    with {:ok, network} <- Virt.Ecto.Type.IPv4.dump(network),
         {:ok, netmask} <- Virt.Ecto.Type.IPv4.dump(netmask),
         {:ok, ip} <- Virt.Ecto.Type.IPv4.dump(ip)
    do
      true
# 4_294_967_295
    end
  end

  @doc """
  Updates a ip_address.
  """
  def update_ip_address(%IpAddress{} = ip_address, attrs) do
    ip_address
    |> IpAddress.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ip_address.
  """
  def delete_ip_address(%IpAddress{} = ip_address) do
    Repo.delete(ip_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ip_address changes.
  """
  def change_ip_address(%IpAddress{} = ip_address, attrs \\ %{}) do
    IpAddress.changeset(ip_address, attrs)
  end
end
