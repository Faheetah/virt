defmodule Virt.Network.Subnets.Subnet do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Virt.Ecto.Type.IPv4

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subnets" do
    field :label, :string
    field :network, IPv4
    field :gateway, IPv4
    field :broadcast, IPv4
    field :netmask, IPv4
    field :subnet, :string, virtual: true
    has_many :ip_addresses, Virt.Network.IpAddresses.IpAddress, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(subnet, attrs) do
    subnet
    |> cast(attrs, [:label, :subnet, :network, :gateway, :broadcast, :netmask])
    |> validate_required([:network, :netmask])
    |> validate_ranges(attrs)
  end

  def validate_ranges(changeset, attrs) do
    with {:ok, first} <- Virt.Ecto.Type.IPv4.dump(attrs["network"]),
         {:ok, netmask} <- Virt.Ecto.Type.IPv4.dump(attrs["netmask"])
    do
      last_ip = 4_294_967_295 - (netmask - first)

      changeset
      |> validate_within_range(attrs, "gateway", first, last_ip)
      |> validate_within_range(attrs, "broadcast", first, last_ip)
    else
      :error -> Ecto.Changeset.add_error(changeset, :netmask, "could not calculate network size", start: attrs["network"], end: attrs["netmask"])
    end
  end

  def validate_within_range(changeset, attrs, name, first, last) do
    case attrs[name] do
      nil ->
        changeset

      item ->
        case Virt.Ecto.Type.IPv4.dump(item) do
          {:ok, item} ->
            cond do
              item < first ->
                {:ok, last_ip} = Virt.Ecto.Type.IPv4.load(last)
                Ecto.Changeset.add_error(changeset, String.to_existing_atom(name), "#{name} less than minimum IP", [{:start, attrs["network"]}, {:end, last_ip}, {String.to_existing_atom(name), item}])
              item > last ->
                {:ok, last_ip} = Virt.Ecto.Type.IPv4.load(last)
                Ecto.Changeset.add_error(changeset, String.to_existing_atom(name), "#{name} greater than maximum IP", [{:start, attrs["network"]}, {:end, last_ip}, {String.to_existing_atom(name), item}])
              true -> changeset
            end

          :error ->
            Ecto.Changeset.add_error(changeset, String.to_existing_atom(name), "could not parse ip", [{String.to_existing_atom(name), attrs[name]}])
        end
    end
  end
end
