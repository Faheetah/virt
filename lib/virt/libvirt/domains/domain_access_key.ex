defmodule Virt.Libvirt.Domains.DomainAccessKey do
  @moduledoc """
  Links a network interface to a domain
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Libvirt.Domains.Domain
  alias Virt.Secrets.AccessKeys.AccessKey

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "domain_access_keys" do
    belongs_to :access_key, AccessKey
    belongs_to :domain, Domain

    timestamps()
  end

  @doc false
  def changeset(domain_interface, attrs) do
    domain_interface
    |> cast(attrs, [:domain_id, :access_key_id])
  end
end
