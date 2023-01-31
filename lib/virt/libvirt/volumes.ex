defmodule Virt.Libvirt.Volumes do
  @moduledoc """
  The Libvirt.Volumes context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Virt.Repo

  alias Virt.Libvirt.Templates
  alias Virt.Libvirt.Volumes.Volume

  @doc """
  Returns the list of volumes.
  """
  @todo "this needs better filtering"
  def list_volumes do
    Repo.all(Volume)
  end

  @doc """
  Gets a single volume.

  Raises `Ecto.NoResultsError` if the Volume does not exist.
  """
  def get_volume!(id), do: Repo.get!(Volume, id)

  @doc """
  Get a volume by name
  """
  def get_volume_by_name!(name), do: Repo.get_by(Volume, name: name)

  @doc """
  Creates a volume.
  """
  def provision_volume(volume, distribution) do
    with volume <- Repo.preload(volume, [:host_distribution, pool: [:host]]),
         {:ok, %{"remote_nonnull_storage_vol" => %{"key" => key}}} <- create_libvirt_volume(volume, distribution),
         {:ok, volume} <- update_volume(volume, %{"created" => true, "key" => key})
    do
      {:ok, volume}
    else
      {:error, error, %Volume{} = volume} ->
        Logger.error(error)
        delete_volume(volume)
        {:error, error}

      {:error, %Libvirt.RPC.Packet{} = packet} ->
        Logger.error(packet)
        delete_volume(volume)
        {:error, packet.payload}
    end
  end

  def create_volume(attrs) do
    changeset = Volume.changeset(%Volume{}, attrs)
    with {:ok, volume} <- Repo.insert(changeset),
         volume <- Repo.preload(volume, [pool: [:host]])
    do
      {:ok, volume}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  defp create_libvirt_volume(volume, nil) do
    with xml <- Templates.render_volume(volume),
         {:ok, socket} <- Libvirt.connect(volume.pool.host.connection_string),
         {:ok, volume} <- Libvirt.storage_vol_create_xml(socket, %{"pool" => %{"name" => volume.pool.name, "uuid" => volume.pool.id}, "xml" => xml, "flags" => 0})
    do
      {:ok, volume}
    end
  end

  defp create_libvirt_volume(volume, base_image) do
    with xml <- Templates.render_volume(volume),
         {:ok, socket} <- Libvirt.connect(volume.pool.host.connection_string),
         {:ok, libvirt_volume} <- Libvirt.storage_vol_create_xml_from(socket, %{"clonevol" => %{"pool" => base_image.pool.name, "name" => base_image.id, "key" => base_image.key}, "pool" => %{"name" => volume.pool.name, "uuid" => volume.pool.id}, "xml" => xml, "flags" => 0}),
         {:ok, _} <- Libvirt.storage_vol_resize(socket, %{"vol" => libvirt_volume["remote_nonnull_storage_vol"], "capacity" => volume.capacity_bytes, "flags" => 0})
    do
      {:ok, libvirt_volume}
    end
  end

  @doc """
  For helping to manage base images
  """
  def download_image(url, to) do
    File.mkdir_p!("images/")
    unless File.exists?("images/#{to}") do
      {:ok, :saved_to_file} = :httpc.request(:get, {String.to_charlist(url), []}, [], [stream: String.to_charlist("images/#{to}")])
    end
    {:ok, "images/#{to}"}
  end

 def create_base_image(%{"url" => url, "name" => name} = attrs) do
    download_image(url, name)
    size = File.stat!("images/#{name}").size
    vol =
      attrs
      |> Map.put("capacity_bytes", size)
      |> create_volume()
      |> then(fn {:ok, v} -> v end)
      |> provision_volume(nil)
      |> then(fn {:ok, v} -> v end)
      |> Virt.Repo.preload(pool: [:host])

    {:ok, socket} = Libvirt.connect(vol.pool.host.connection_string)

    if Keyword.get(Application.fetch_env!(:libvirt, :rpc), :backend) != Libvirt.RPC.Backends.Test do
      {:ok, nil} = Libvirt.storage_vol_upload(socket, %{"vol" => %{"pool" => vol.pool.name, "name" => vol.id, "key" => vol.key}, "offset" => 0, "length" => size, "flags" => 0}, File.stream!("images/#{name}", [], 262_148))
      {:ok, vol}
    else
      {:ok, vol}
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
    with :ok <- delete_libvirt_volume(volume),
         {:ok, volume} <- Repo.delete(volume)
    do
      {:ok, volume}
    else
      {:error, packet} ->
        # also delete volume if storage pool does not exist
        if packet.payload =~ "VIR_ERR_NO_STORAGE_POOL" do
          Repo.delete(volume)
        else
          {:error, packet}
        end
      error -> {:error, error}
    end
  end

  defp delete_libvirt_volume(volume) do
    with volume <- Repo.preload(volume, [pool: [:host]]),
         {:ok, socket} <- Libvirt.connect(volume.pool.host.connection_string),
         _ <- Libvirt.storage_vol_wipe(socket, %{"vol" => %{"pool" => volume.pool.name, "name" => volume.id, "key" => volume.key}, "flags" => 0}),
         {:ok, nil} <- Libvirt.storage_vol_delete(socket, %{"vol" => %{"pool" => volume.pool.name, "name" => volume.id, "key" => volume.key}, "flags" => 0})
    do
      :ok
    else
      {:error, packet} ->
        if packet.payload =~ "VIR_ERR_NO_STORAGE_VOL" do
          :ok
        else
          {:error, packet}
        end
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking volume changes.
  """
  def change_volume(%Volume{} = volume, attrs \\ %{}) do
    Volume.changeset(volume, attrs)
  end

  def synchronize_libvirt_volume(pool_id, volume) do
    name = volume["name"]
    key = volume["key"]
    Virt.Libvirt.Volumes.create_volume(%{
      "name" => name,
      "id" => name,
      "key" => key,
      "capacity_bytes" => 0,
      "pool_id" => pool_id
    })
  end
end
