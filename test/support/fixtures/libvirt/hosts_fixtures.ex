defmodule Virt.Libvirt.HostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Libvirt.Hosts` context.
  """

  @doc """
  Generate a host.
  """
  def host_fixture(attrs \\ %{}) do
    {:ok, host} =
      attrs
      |> Enum.into(%{
        connection_string: "some connection_string",
        name: "some name"
      })
      |> Virt.Libvirt.Hosts.create_host()

    host
  end
end
