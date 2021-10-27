defmodule Virt.Libvirt.Volumes do
  @moduledoc """
  The Libvirt.Volumes context.
  """

  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Libvirt.Templates
  alias Virt.Libvirt.Volumes.Volume

  @doc """
  Returns the list of volumes.
  """
  def list_volumes do
    Repo.all(Volume)
  end

  @doc """
  Gets a single volume.

  Raises `Ecto.NoResultsError` if the Volume does not exist.
  """
  def get_volume!(id), do: Repo.get!(Volume, id)

  @doc """
  Creates a volume.
  """
  def create_volume(attrs \\ %{}) do
    with changeset <- Volume.changeset(%Volume{}, attrs),
         {:ok, volume} <- Repo.insert(changeset),
         volume <- Repo.preload(volume, [pool: [:host]]),
         {:ok, _} <- create_libvirt_volume(volume),
         {:ok, volume} <- update_volume(volume, %{"created" => true})
    do
      volume
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, error, %Volume{} = volume} ->
        delete_volume(volume)
        {:error, error}
    end
  end

  defp create_libvirt_volume(volume) do
    with xml <- Templates.render_volume(volume),
         {:ok, socket} <- Libvirt.connect(volume.pool.host.connection_string),
         {:ok, volume} <- Libvirt.storage_vol_create_xml(socket, %{"pool" => %{"name" => volume.pool.name, "uuid" => volume.pool.id}, "xml" => xml, "flags" => 0})
    do
      {:ok, volume}
    end
  end

  @doc """
  Updates a volume.
  """
  def update_volume(%Volume{} = volume, attrs) do
    volume
    |> Volume.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a volume.
  """
  def delete_volume(%Volume{} = volume) do
    Repo.delete(volume)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking volume changes.
  """
  def change_volume(%Volume{} = volume, attrs \\ %{}) do
    Volume.changeset(volume, attrs)
  end
end
