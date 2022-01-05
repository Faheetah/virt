defmodule Virt.Network.Subnets do
  @moduledoc """
  The Network.Subnets context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Network.Subnets.Subnet

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

  @doc """
  Creates a subnet.

  ## Examples

      iex> create_subnet(%{field: value})
      {:ok, %Subnet{}}

      iex> create_subnet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subnet(attrs \\ %{}) do
    %Subnet{}
    |> Subnet.changeset(attrs)
    |> Repo.insert()
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
