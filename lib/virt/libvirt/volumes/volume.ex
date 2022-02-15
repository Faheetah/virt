defmodule Virt.Libvirt.Volumes.Volume do
  @moduledoc """
  A representation of a Libvirt volume resource
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Domains.DomainDisk
  alias Virt.Libvirt.Hosts.HostDistribution
  alias Virt.Libvirt.Pools.Pool

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "volumes" do
    field :name, :string
    field :key, :string
    field :type, :string, default: "raw"
    field :capacity_bytes, :integer
    field :created, :boolean, default: false
    belongs_to :pool, Pool
    has_one :domain_disk, DomainDisk, on_delete: :delete_all
    has_one :host_distribution, HostDistribution

    timestamps()
  end

  @doc false
  def changeset(volume, attrs) do
    volume
    |> cast(attrs, [:name, :key, :type, :capacity_bytes, :pool_id, :created])
    |> cast_assoc(:host_distribution)
    |> validate_required([:capacity_bytes, :pool_id])
  end
end
