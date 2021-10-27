defmodule Virt.Libvirt.Domains.Domain do
  @moduledoc """
  A Libvirt domain resource
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Hosts.Host
  alias Virt.Libvirt.Volumes.Volume

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "domains" do
    field :memory_bytes, :integer
    field :name, :string
    field :vcpus, :integer
    field :created, :boolean, default: false
    belongs_to :host, Host

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:name, :memory_bytes, :vcpus, :host_id])
    |> validate_required([:name, :memory_bytes, :vcpus])
  end
end
