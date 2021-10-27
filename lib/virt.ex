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

  def add_pool(host, path, name \\ nil) do
    Virt.Libvirt.Pools.create_pool(%{name: name || path, path: path, type: "dir", host_id: host.id})
  end
end
