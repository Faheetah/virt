defmodule Virt.Network.IpAddressesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Network.IpAddresses` context.
  """

  @doc """
  Generate a ip_address.
  """
  def ip_address_fixture(attrs \\ %{}) do
    {:ok, ip_address} =
      attrs
      |> Enum.into(%{
        address: 42,
        label: "some label"
      })
      |> Virt.Network.IpAddresses.create_ip_address()

    ip_address
  end
end
