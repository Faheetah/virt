defmodule Virt.Libvirt.HostsTest do
  use Virt.DataCase

  alias Virt.Libvirt.Hosts

  describe "hosts" do
    alias Virt.Libvirt.Hosts.Host

    import Virt.Libvirt.HostsFixtures

    @invalid_attrs %{connection_string: nil, name: nil}

    @tag :skip
    test "list_hosts/0 returns all hosts" do
      host = host_fixture()
      assert Hosts.list_hosts() == [host]
    end

    @tag :skip
    test "get_host!/1 returns the host with given id" do
      host = host_fixture()
      assert Hosts.get_host!(host.id) == host
    end

    @tag :skip
    test "create_host/1 with valid data creates a host" do
      valid_attrs = %{connection_string: "some connection_string", name: "some name"}

      assert {:ok, %Host{} = host} = Hosts.create_host(valid_attrs)
      assert host.connection_string == "some connection_string"
      assert host.name == "some name"
    end

    @tag :skip
    test "create_host/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hosts.create_host(@invalid_attrs)
    end

    @tag :skip
    test "update_host/2 with valid data updates the host" do
      host = host_fixture()
      update_attrs = %{connection_string: "some updated connection_string", name: "some updated name"}

      assert {:ok, %Host{} = host} = Hosts.update_host(host, update_attrs)
      assert host.connection_string == "some updated connection_string"
      assert host.name == "some updated name"
    end

    @tag :skip
    test "update_host/2 with invalid data returns error changeset" do
      host = host_fixture()
      assert {:error, %Ecto.Changeset{}} = Hosts.update_host(host, @invalid_attrs)
      assert host == Hosts.get_host!(host.id)
    end

    @tag :skip
    test "delete_host/1 deletes the host" do
      host = host_fixture()
      assert {:ok, %Host{}} = Hosts.delete_host(host)
      assert_raise Ecto.NoResultsError, fn -> Hosts.get_host!(host.id) end
    end

    @tag :skip
    test "change_host/1 returns a host changeset" do
      host = host_fixture()
      assert %Ecto.Changeset{} = Hosts.change_host(host)
    end
  end
end
