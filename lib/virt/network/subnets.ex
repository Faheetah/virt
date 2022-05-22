defmodule Virt.Network.Subnets do
  @moduledoc """
  The Network.Subnets context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Ecto.Type.IPv4
  alias Virt.Network.Subnets.Subnet
  alias Virt.Network.IpAddresses

  @doc """
  Returns the list of subnets.

  ## Examples

      iex> list_subnets()
      [%Subnet{}, ...]

  """
  def list_subnets do
    Repo.all(Subnet)
  end

  @doc """
  Gets a single subnet.

  Raises `Ecto.NoResultsError` if the Subnet does not exist.

  ## Examples

      iex> get_subnet!(123)
      %Subnet{}

      iex> get_subnet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subnet!(id), do: Repo.get!(Subnet, id)

  def get_subnet(id), do: Repo.get(Subnet, id)

  def find_available_ip(subnet) do
    {:ok, first_ip} = IPv4.dump(subnet.gateway)
    {:ok, last_ip} = IPv4.dump(subnet.broadcast)
    found = Enum.find(first_ip+1..last_ip-1, fn address_value ->
      {:ok, address} = IPv4.load(address_value)
      nil == IpAddresses.get_ip_address_by_address(address)
    end)

    if found != nil do
      IPv4.load(found)
    else
      {:error, "No IP found in subnet"}
    end
  end

  @doc """
  Creates a subnet.

  ## Examples

      iex> create_subnet(%{field: value})
      {:ok, %Subnet{}}

      iex> create_subnet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subnet(attrs \\ %{}) do
    [network, cidr] = String.split(attrs["subnet"], "/")
    {:ok, network_value} = IPv4.dump(network)
    {cidr_value, _} =  Integer.parse(cidr)
    {:ok, netmask} = IPv4.load(4_294_967_295 - Integer.pow(2,32 - cidr_value) + 1)
    {:ok, netmask_value} = IPv4.dump(netmask)
    {:ok, broadcast} = IPv4.load(4_294_967_295 - (netmask_value - network_value))
    {:ok, gateway} = IPv4.load(network_value + 1)

    {:ok, subnet} =
      %Subnet{}
      |> Subnet.changeset(%{
        "label" => attrs["label"],
        "network" => network,
        "gateway" => gateway,
        "broadcast" => broadcast,
        "netmask" => netmask
      })
      |> Repo.insert()

    IpAddresses.create_ip_address(%{"label" => "network", "address" => network, "subnet_id" => subnet.id})
    IpAddresses.create_ip_address(%{"label" => "gateway", "address" => gateway, "subnet_id" => subnet.id})
    IpAddresses.create_ip_address(%{"label" => "broadcast", "address" => broadcast, "subnet_id" => subnet.id})
  end

  def calculate_netmask(cidr) do
    {cidr_value, ""} = Integer.parse(cidr)
    {:ok, cidr} = IPv4.load(4_294_967_295 - Integer.pow(2,32 - cidr_value) + 1)
    cidr
  end

  def calculate_cidr(netmask) do
    {:ok, netmask_value} = IPv4.dump(netmask)
    trunc(32 - :math.log2((4_294_967_295 - netmask_value) + 1))
  end

  @doc """
  Updates a subnet.

  ## Examples

      iex> update_subnet(subnet, %{field: new_value})
      {:ok, %Subnet{}}

      iex> update_subnet(subnet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subnet(%Subnet{} = subnet, attrs) do
    subnet
    |> Subnet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subnet.

  ## Examples

      iex> delete_subnet(subnet)
      {:ok, %Subnet{}}

      iex> delete_subnet(subnet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subnet(%Subnet{} = subnet) do
    Repo.delete(subnet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subnet changes.

  ## Examples

      iex> change_subnet(subnet)
      %Ecto.Changeset{data: %Subnet{}}

  """
  def change_subnet(%Subnet{} = subnet, attrs \\ %{}) do
    Subnet.changeset(subnet, attrs)
  end
end
