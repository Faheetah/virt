defmodule Virt.Libvirt.Domains.DomainDisk do
  @moduledoc """
  A mounted disk to a domain linking it to a volume
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Domains.Domain
  alias Virt.Libvirt.Volumes.Volume

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "domain_disks" do
    field :device, :string
    belongs_to :domain, Domain
    belongs_to :volume, Volume

    timestamps()
  end

  @doc false
  def changeset(domain_disk, attrs) do
    domain_disk
    |> cast(attrs, [:domain_id, :volume_id, :device])
    |> cast_assoc(:domain)
    |> cast_assoc(:volume)
    |> validate_required([:device])
  end
end
