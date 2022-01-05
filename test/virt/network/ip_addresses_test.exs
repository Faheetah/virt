defmodule Virt.Network.IpAddressesTest do
  use Virt.DataCase

  alias Virt.Network.IpAddresses

  describe "ip_addresses" do
    alias Virt.Network.IpAddresses.IpAddress

    import Virt.Network.IpAddressesFixtures

    @invalid_attrs %{address: nil, label: nil}

    test "list_ip_addresses/0 returns all ip_addresses" do
      ip_address = ip_address_fixture()
      assert IpAddresses.list_ip_addresses() == [ip_address]
    end

    test "get_ip_address!/1 returns the ip_address with given id" do
      ip_address = ip_address_fixture()
      assert IpAddresses.get_ip_address!(ip_address.id) == ip_address
    end

    test "create_ip_address/1 with valid data creates a ip_address" do
      valid_attrs = %{address: 42, label: "some label"}

      assert {:ok, %IpAddress{} = ip_address} = IpAddresses.create_ip_address(valid_attrs)
      assert ip_address.address == 42
      assert ip_address.label == "some label"
    end

    test "create_ip_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = IpAddresses.create_ip_address(@invalid_attrs)
    end

    test "update_ip_address/2 with valid data updates the ip_address" do
      ip_address = ip_address_fixture()
      update_attrs = %{address: 43, label: "some updated label"}

      assert {:ok, %IpAddress{} = ip_address} = IpAddresses.update_ip_address(ip_address, update_attrs)
      assert ip_address.address == 43
      assert ip_address.label == "some updated label"
    end

    test "update_ip_address/2 with invalid data returns error changeset" do
      ip_address = ip_address_fixture()
      assert {:error, %Ecto.Changeset{}} = IpAddresses.update_ip_address(ip_address, @invalid_attrs)
      assert ip_address == IpAddresses.get_ip_address!(ip_address.id)
    end

    test "delete_ip_address/1 deletes the ip_address" do
      ip_address = ip_address_fixture()
      assert {:ok, %IpAddress{}} = IpAddresses.delete_ip_address(ip_address)
      assert_raise Ecto.NoResultsError, fn -> IpAddresses.get_ip_address!(ip_address.id) end
    end

    test "change_ip_address/1 returns a ip_address changeset" do
      ip_address = ip_address_fixture()
      assert %Ecto.Changeset{} = IpAddresses.change_ip_address(ip_address)
    end
  end
end
