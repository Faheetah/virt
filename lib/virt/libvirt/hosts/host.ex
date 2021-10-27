defmodule Virt.Libvirt.Hosts.Host do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :connection_string, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [:name, :connection_string])
    |> validate_required([:name, :connection_string])
  end
end
