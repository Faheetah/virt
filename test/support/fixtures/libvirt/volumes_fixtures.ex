defmodule Virt.Libvirt.VolumesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Libvirt.Volumes` context.
  """

  @doc """
  Generate a volume.
  """
  def volume_fixture(attrs \\ %{}) do
    {:ok, volume} =
      attrs
      |> Enum.into(%{
        capacity_bytes: 42,
        name: "some name",
        path: "some path"
      })
      |> Virt.Libvirt.Volumes.create_volume()

    volume
  end
end
