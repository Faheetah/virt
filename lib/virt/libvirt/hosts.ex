defmodule Virt.Libvirt.Hosts do
  @moduledoc """
  The Libvirt.Hosts context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Libvirt.Hosts.Host

  @doc """
  Returns the list of hosts.
  """
  def list_hosts do
    Repo.all(Host)
  end

  @doc """
  Gets a single host.

  Raises `Ecto.NoResultsError` if the Host does not exist.
  """
  def get_host!(id), do: Repo.get!(Host, id)

  @doc """
  Gets a host by name.
  """
  def get_host_by_name!(name) do
    Repo.get_by(Host, name: name)
  end

  @doc """
  Creates a host.
  """
  def create_host(attrs \\ %{}) do
    %Host{}
    |> Host.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a host.
  """
  def update_host(%Host{} = host, attrs) do
    host
    |> Host.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a host.

  WARNING: Deleting a host orphans all assets on the host. This is irreversible.
  """
  def delete_host(%Host{} = host) do
    Repo.delete(host)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking host changes.
  """
  def change_host(%Host{} = host, attrs \\ %{}) do
    Host.changeset(host, attrs)
  end
end
