defmodule Virt.Libvirt.DomainsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Libvirt.Domains` context.
  """

  @doc """
  Generate a domain.
  """
  def domain_fixture(attrs \\ %{}) do
    {:ok, domain} =
      attrs
      |> Enum.into(%{
        memory_bytes: 42,
        name: "some name",
        vcpus: 42
      })
      |> Virt.Libvirt.Domains.create_domain()

    domain
  end
end
