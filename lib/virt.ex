defmodule Virt do
  @moduledoc """
  Virt keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Creates a libvirt host with the connection string as the name
  """
  def add_host(name) do
    with {:ok, host} <- Virt.Libvirt.Hosts.create_host(%{name: name, connection_string: name}) do
      host
    end
  end

  def add_pool(host, path, name) do
    Virt.Libvirt.Pools.create_pool(%{name: name, path: path, type: "dir", host_id: host.id})
  end

  def add_volume(pool, name, capacity_bytes \\ 1048576) do
    Virt.Libvirt.Volumes.create_volume(%{name: name, capacity_bytes: capacity_bytes, pool_id: pool.id})
  end
end
