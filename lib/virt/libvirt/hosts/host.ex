defmodule Virt.Libvirt.Hosts.Host do
  @moduledoc """
  A Libvirt host with connection information
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Pools.Pool
  alias Virt.Libvirt.Domains.Domain

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :connection_string, :string
    field :name, :string
    has_many :pools, Pool
    has_many :domains, Domain

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [:name, :connection_string])
    |> validate_required([:name, :connection_string])
    |> unique_constraint([:name, :connection_string])
  end
end
