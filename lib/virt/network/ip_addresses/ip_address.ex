defmodule Virt.Network.IpAddresses.IpAddress do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Ecto.Type.IPv4

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ip_addresses" do
    field :label, :string
    field :address, IPv4
    belongs_to :subnet, Virt.Network.Subnets.Subnet
    has_one :domain_interface, Virt.Libvirt.Domains.DomainInterface, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(ip_address, attrs) do
    ip_address
    |> cast(attrs, [:label, :address, :subnet_id])
    |> validate_required([:address, :subnet_id])
  end
end
