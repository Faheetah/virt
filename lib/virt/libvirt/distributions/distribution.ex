defmodule Virt.Libvirt.Distributions.Distribution do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Virt.Libvirt.Hosts.HostDistribution

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "distributions" do
    field :name, :string
    field :key, :string
    field :source, :string
    has_many :host_distributions, HostDistribution

    timestamps()
  end

  @doc false
  def changeset(distributions, attrs) do
    distributions
    |> cast(attrs, [:name, :source, :key])
    |> validate_required([:name, :source, :key])
    |> unique_constraint([:key])
  end
end
