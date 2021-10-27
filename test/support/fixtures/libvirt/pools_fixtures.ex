defmodule Virt.Libvirt.PoolsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Libvirt.Pools` context.
  """

  @doc """
  Generate a pool.
  """
  def pool_fixture(attrs \\ %{}) do
    {:ok, pool} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Virt.Libvirt.Pools.create_pool()

    pool
  end
end
