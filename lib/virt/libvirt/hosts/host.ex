defmodule Virt.Libvirt.Hosts.Host do
  @moduledoc """
  A Libvirt host with connection information
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Pools.Pool
  alias Virt.Libvirt.Domains.Domain
  alias Virt.Libvirt.Hosts.HostDistribution

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :connection_string, :string
    field :name, :string
    field :status, :string
    has_many :pools, Pool
    has_many :domains, Domain
    has_many :host_distributions, HostDistribution

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [:name, :connection_string, :status])
    |> cast_assoc(:host_distributions)
    |> validate_required([:name, :connection_string, :status])
    |> unique_constraint([:name, :connection_string])
  end
end
