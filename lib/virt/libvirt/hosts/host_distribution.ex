defmodule Virt.Libvirt.Hosts.HostDistribution do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Virt.Libvirt.Distributions.Distribution
  alias Virt.Libvirt.Hosts.Host
  alias Virt.Libvirt.Volumes.Volume

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "host_distribution" do
    belongs_to :host, Host
    belongs_to :distribution, Distribution
    belongs_to :volume, Volume

    timestamps()
  end

  @doc false
  def changeset(host_distribution, attrs) do
    host_distribution
    |> cast(attrs, [:distribution_id, :host_id, :volume_id])
    |> cast_assoc(:distribution)
    |> cast_assoc(:host)
    |> cast_assoc(:volume)
    |> unique_constraint([:host_id, :distribution_id])
  end
end
