defmodule Virt.Libvirt.Pools do
  @moduledoc """
  The Libvirt.Pools context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Libvirt.Pools.Pool
  alias Virt.Libvirt.Templates

  @doc """
  Returns the list of pools.
  """
  def list_pools do
    Repo.all(Pool)
  end

  @doc """
  Gets a single pool.

  Raises `Ecto.NoResultsError` if the Pool does not exist.
  """
  def get_pool!(id) do
    Pool
    |> preload(:host)
    |> Repo.get!(id)
  end

  @doc """
  Gets a pool by name
  """
  def get_pool_by_name!(host_id, name) do
    Repo.get_by(Pool, name: name, host_id: host_id)
  end

  def get_pool_by_name(host_id, name) do
    pool = get_pool_by_name!(host_id, name)

    if pool do
      {:ok, pool}
    else
      {:error, "could not find pool #{name} on host #{host_id}"}
    end
  end

  @doc """
  Creates a pool.
  """
  def create_pool(attrs \\ %{}) do
    with changeset <- Pool.changeset(%Pool{}, attrs),
         {:ok, pool} <- Repo.insert(changeset),
         pool <- Repo.preload(pool, [:host]),
         {:ok, _} <- create_libvirt_pool(pool),
         {:ok, pool} <- update_pool(pool, %{"created" => true})
    do
      {:ok, pool}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, error, %Pool{} = pool} ->
        delete_pool(pool)
        {:error, error}

      _ -> {:error, "an unspecified error occurred"}
    end
  end

  defp create_libvirt_pool(pool) do
    with xml <- Templates.render_pool(pool),
         {:ok, socket} <- Libvirt.connect(pool.host.connection_string),
         {:ok, %{"remote_nonnull_storage_pool" => pool}} <- Libvirt.storage_pool_define_xml(socket, %{"xml" => xml, "flags" => 0}),
         {:ok, nil} <- Libvirt.storage_pool_build(socket, %{"pool" => pool, "flags" => 0}),
         {:ok, nil} <- Libvirt.storage_pool_create(socket, %{"pool" => pool, "flags" => 0}),
         {:ok, nil} <- Libvirt.storage_pool_set_autostart(socket, %{"pool" => pool, "autostart" => 1})
    do
      {:ok, pool}
    else
      {:error, %Libvirt.RPC.Packet{payload: error}} ->
        {:error, error, pool}
      {:error, :econnrefused} ->
        {:error, "Could not connect to Libvirt host #{pool.host.connection_string}"}
      _ -> {:error, "an unspecified error occurred"}
    end
  end

  @doc """
  Updates a pool.
  """
  def update_pool(%Pool{} = pool, attrs) do
    pool
    |> Pool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pool.
  """
  def delete_pool(%Pool{} = pool) do
    with :ok <- delete_libvirt_pool(pool),
         {:ok, pool} <- Repo.delete(pool)
    do
      {:ok, pool}
    else
      {:error, error} ->
        if error.payload =~ "VIR_ERR_NO_STORAGE_POOL" do
          Repo.delete(pool)
        end
    end
  end

  defp delete_libvirt_pool(pool) do
    with pool <- Repo.preload(pool, [:host]),
         {:ok, socket} <- Libvirt.connect(pool.host.connection_string),
         _ <- Libvirt.storage_pool_destroy(socket, %{"pool" => %{"name" => pool.name, "uuid" => pool.id}}),
         {:ok, nil} <- Libvirt.storage_pool_undefine(socket, %{"pool" => %{"name" => pool.name, "uuid" => pool.id}})
    do
      :ok
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pool changes.
  """
  def change_pool(%Pool{} = pool, attrs \\ %{}) do
    Pool.changeset(pool, attrs)
  end
end
