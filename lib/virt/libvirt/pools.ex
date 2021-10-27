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
  Creates a pool.
  """
  def create_pool(attrs \\ %{}) do
    with changeset <- Pool.changeset(%Pool{}, attrs),
         {:ok, pool} <- Repo.insert(changeset),
         pool <- Repo.preload(pool, [:host]),
         {:ok, nil} <- create_libvirt_pool(pool),
         {:ok, pool} <- update_pool(pool, %{"status" => "COMPLETE"})
    do
      pool
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, error, %Pool{} = pool} ->
        delete_pool(pool)
        {:error, error}

    end
  end

  defp create_libvirt_pool(pool) do
    with xml <- Templates.render_pool(pool),
         {:ok, socket} <- Libvirt.connect(pool.host.connection_string),
         {:ok, %{"remote_nonnull_storage_pool" => pool}} <- Libvirt.storage_pool_define_xml(socket, %{"xml" => xml, "flags" => 0}),
         nil <- Libvirt.storage_pool_build(socket, %{"pool" => pool, "flags" => 0}),
         nil <- Libvirt.storage_pool_create(socket, %{"pool" => pool, "flags" => 0})
    do
      pool
    else
      {:error, %Libvirt.RPC.Packet{payload: error}} ->
        {:error, error, pool}
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
    Repo.delete(pool)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pool changes.
  """
  def change_pool(%Pool{} = pool, attrs \\ %{}) do
    Pool.changeset(pool, attrs)
  end
end
