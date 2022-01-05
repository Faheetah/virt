defmodule Virt.Network.SubnetsTest do
  use Virt.DataCase

  alias Virt.Network.Subnets

  describe "subnets" do
    alias Virt.Network.Subnets.Subnet

    import Virt.Network.SubnetsFixtures

    @invalid_attrs %{end: nil, label: nil, size: nil, start: nil}

    test "list_subnets/0 returns all subnets" do
      subnet = subnet_fixture()
      assert Subnets.list_subnets() == [subnet]
    end

    test "get_subnet!/1 returns the subnet with given id" do
      subnet = subnet_fixture()
      assert Subnets.get_subnet!(subnet.id) == subnet
    end

    test "create_subnet/1 with valid data creates a subnet" do
      valid_attrs = %{end: 42, label: "some label", size: 42, start: 42}

      assert {:ok, %Subnet{} = subnet} = Subnets.create_subnet(valid_attrs)
      assert subnet.end == 42
      assert subnet.label == "some label"
      assert subnet.size == 42
      assert subnet.start == 42
    end

    test "create_subnet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subnets.create_subnet(@invalid_attrs)
    end

    test "update_subnet/2 with valid data updates the subnet" do
      subnet = subnet_fixture()
      update_attrs = %{end: 43, label: "some updated label", size: 43, start: 43}

      assert {:ok, %Subnet{} = subnet} = Subnets.update_subnet(subnet, update_attrs)
      assert subnet.end == 43
      assert subnet.label == "some updated label"
      assert subnet.size == 43
      assert subnet.start == 43
    end

    test "update_subnet/2 with invalid data returns error changeset" do
      subnet = subnet_fixture()
      assert {:error, %Ecto.Changeset{}} = Subnets.update_subnet(subnet, @invalid_attrs)
      assert subnet == Subnets.get_subnet!(subnet.id)
    end

    test "delete_subnet/1 deletes the subnet" do
      subnet = subnet_fixture()
      assert {:ok, %Subnet{}} = Subnets.delete_subnet(subnet)
      assert_raise Ecto.NoResultsError, fn -> Subnets.get_subnet!(subnet.id) end
    end

    test "change_subnet/1 returns a subnet changeset" do
      subnet = subnet_fixture()
      assert %Ecto.Changeset{} = Subnets.change_subnet(subnet)
    end
  end
end
