defmodule Virt.Libvirt.VolumesTest do
  use Virt.DataCase

  alias Virt.Libvirt.Volumes

  describe "volumes" do
    alias Virt.Libvirt.Volumes.Volume

    import Virt.Libvirt.VolumesFixtures

    @invalid_attrs %{capacity_bytes: nil, name: nil, path: nil}

    test "list_volumes/0 returns all volumes" do
      volume = volume_fixture()
      assert Volumes.list_volumes() == [volume]
    end

    test "get_volume!/1 returns the volume with given id" do
      volume = volume_fixture()
      assert Volumes.get_volume!(volume.id) == volume
    end

    test "create_volume/1 with valid data creates a volume" do
      valid_attrs = %{capacity_bytes: 42, name: "some name", path: "some path"}

      assert {:ok, %Volume{} = volume} = Volumes.create_volume(valid_attrs)
      assert volume.capacity_bytes == 42
      assert volume.name == "some name"
      assert volume.path == "some path"
    end

    test "create_volume/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Volumes.create_volume(@invalid_attrs)
    end

    test "update_volume/2 with valid data updates the volume" do
      volume = volume_fixture()
      update_attrs = %{capacity_bytes: 43, name: "some updated name", path: "some updated path"}

      assert {:ok, %Volume{} = volume} = Volumes.update_volume(volume, update_attrs)
      assert volume.capacity_bytes == 43
      assert volume.name == "some updated name"
      assert volume.path == "some updated path"
    end

    test "update_volume/2 with invalid data returns error changeset" do
      volume = volume_fixture()
      assert {:error, %Ecto.Changeset{}} = Volumes.update_volume(volume, @invalid_attrs)
      assert volume == Volumes.get_volume!(volume.id)
    end

    test "delete_volume/1 deletes the volume" do
      volume = volume_fixture()
      assert {:ok, %Volume{}} = Volumes.delete_volume(volume)
      assert_raise Ecto.NoResultsError, fn -> Volumes.get_volume!(volume.id) end
    end

    test "change_volume/1 returns a volume changeset" do
      volume = volume_fixture()
      assert %Ecto.Changeset{} = Volumes.change_volume(volume)
    end
  end
end
