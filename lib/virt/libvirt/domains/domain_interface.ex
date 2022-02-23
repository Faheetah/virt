defmodule Virt.Libvirt.Domains.DomainInterface do
  @moduledoc """
  Links a network interface to a domain
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Domains.Domain
  alias Virt.Network.IpAddresses.IpAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "domain_interfaces" do
    field :type, :string
    field :mac, :string
    field :bridge, :string
    belongs_to :ip_address, IpAddress
    belongs_to :domain, Domain

    timestamps()
  end

  @doc false
  def changeset(domain_interface, attrs) do
    domain_interface
    |> cast(attrs, [:domain_id, :type, :mac, :bridge, :ip_address_id])
    |> cast_assoc(:domain)
  end
end
