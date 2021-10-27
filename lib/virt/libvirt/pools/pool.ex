defmodule Virt.Libvirt.Pools.Pool do
  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Hosts.Host

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pools" do
    field :name, :string
    field :type, :string
    field :path, :string
    field :autostart, :boolean, default: true
    field :status, :string, default: "PROVISIONING"
    belongs_to :host, Host

    timestamps()
  end

  @doc false
  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:name, :type, :path, :autostart, :status, :host_id])
    |> validate_required([:name, :type, :path])
    |> unique_constraint([:host_id, :name])
    |> unique_constraint([:host_id, :path])
  end
end
