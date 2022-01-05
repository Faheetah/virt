defmodule Virt.Network.SubnetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Virt.Network.Subnets` context.
  """

  @doc """
  Generate a subnet.
  """
  def subnet_fixture(attrs \\ %{}) do
    {:ok, subnet} =
      attrs
      |> Enum.into(%{
        end: 42,
        label: "some label",
        size: 42,
        start: 42
      })
      |> Virt.Network.Subnets.create_subnet()

    subnet
  end
end
