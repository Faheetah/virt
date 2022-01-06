defmodule Virt.Libvirt.Distributions do
  @moduledoc """
  Manages OS distributions for base images
  """

  import Ecto.Query, warn: false
  require Logger

  alias Virt.Repo

  alias Virt.Libvirt.Distributions.Distribution
  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Pools
  alias Virt.Libvirt.Volumes

  @doc """
  Returns the list of distributions.
  """
  def list_distributions do
    Repo.all(Distribution)
  end

  @doc """
  Gets a single distribution by name
  """
  def get_distribution_by_key!(key) do
    Repo.get_by(Distribution, [key: key])
  end

  @doc """
  Creates a distribution entry, does not synchronize to hosts
  but kicks off a task to synchronize to hosts
  """
  def create_distribution(attrs \\ %{}) do
    %Distribution{}
    |> Distribution.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Synchronizes a distribution to all hosts
  This will be a provisioning task later, do it ad hoc for now
  """
  def synchronize_distribution(distribution) do
    {:ok, _} = Volumes.download_image(distribution.source, distribution.key)

    Hosts.list_hosts
    |> Enum.map(&start_transfer(&1, distribution))
  end

  defp start_transfer(host, distribution) do
    host = Repo.preload(host, [:host_distributions])

    Task.Supervisor.async(Virt.TaskSupervisor, fn ->
      pool =
        case Pools.get_pool_by_name!(host.id, "base_images") do
          nil ->
            Virt.Libvirt.Pools.create_pool(%{
              name: "base_images",
              path: "/tmp/pool",
              type: "dir",
              host_id: host.id
            })

          pool -> pool
        end

      {:ok, volume} =
        Volumes.create_base_image(%{
          "url" => distribution.source,
          "name" => distribution.key,
          "pool_id" => pool.id
        })

      # this isn't updating
      Hosts.update_host(host, %{
        "host_distributions" => [
          %{
            "host_id" => host.id,
            "distribution_id" => distribution.id,
            "volume_id" => volume.id
          }
        ]
      })
    end, restart: :transient)
  end

  def delete_distribution(distribution) do
    Virt.Repo.delete(distribution)
  end
end
