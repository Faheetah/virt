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

  def get_ip_address_by_address(address) do
    Repo.get_by(IpAddress, [address: address])
  end

  @doc """
  Creates a ip_address.
  """
  def create_ip_address(attrs \\ %{}) do
    changeset = IpAddress.changeset(%IpAddress{}, attrs)
    subnet = Subnets.get_subnet!(attrs["subnet_id"])
    if address_in_subnet(attrs["address"], subnet.network, subnet.broadcast) do
      Repo.insert(changeset)
    else
      Ecto.Changeset.add_error(changeset, :address, "not in range", address: attrs["address"], network: subnet.network, broadcast: subnet.broadcast)
    end
  end

  def address_in_subnet(ip, network, broadcast) do
    with {:ok, network} <- Virt.Ecto.Type.IPv4.dump(network),
         {:ok, broadcast} <- Virt.Ecto.Type.IPv4.dump(broadcast),
         {:ok, ip} <- Virt.Ecto.Type.IPv4.dump(ip)
    do
      ip > network and ip < broadcast
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
