defmodule Virt.Libvirt.Domains.Domain do
  @moduledoc """
  A Libvirt domain resource
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Domains.DomainDisk
  alias Virt.Libvirt.Domains.DomainInterface
  alias Virt.Libvirt.Hosts.Host

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "domains" do
    field :name, :string
    field :vcpus, :integer
    field :memory_bytes, :integer
    field :created, :boolean, default: false
    belongs_to :host, Host
    has_many :domain_disks, DomainDisk, on_delete: :delete_all
    has_many :domain_interfaces, DomainInterface, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:name, :memory_bytes, :vcpus, :host_id, :created])
    |> cast_assoc(:domain_disks)
    |> cast_assoc(:domain_interfaces)
    |> validate_required([:name, :memory_bytes, :vcpus])
    |> validate_inclusion(:vcpus, 1..16, message: "VCPU must be max of 16")
    |> validate_length(:name, max: 128)
  end
end
