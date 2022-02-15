defmodule Virt.Libvirt.PoolsTest do
  use Virt.DataCase

  alias Virt.Libvirt.Pools

  describe "pools" do
    alias Virt.Libvirt.Pools.Pool

    import Virt.Libvirt.PoolsFixtures

    @invalid_attrs %{name: nil}

    @tag :skip
    test "list_pools/0 returns all pools" do
      pool = pool_fixture()
      assert Pools.list_pools() == [pool]
    end

    @tag :skip
    test "get_pool!/1 returns the pool with given id" do
      pool = pool_fixture()
      assert Pools.get_pool!(pool.id) == pool
    end

    @tag :skip
    test "create_pool/1 with valid data creates a pool" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Pool{} = pool} = Pools.create_pool(valid_attrs)
      assert pool.name == "some name"
    end

    @tag :skip
    test "create_pool/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pools.create_pool(@invalid_attrs)
    end

    @tag :skip
    test "update_pool/2 with valid data updates the pool" do
      pool = pool_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Pool{} = pool} = Pools.update_pool(pool, update_attrs)
      assert pool.name == "some updated name"
    end

    @tag :skip
    test "update_pool/2 with invalid data returns error changeset" do
      pool = pool_fixture()
      assert {:error, %Ecto.Changeset{}} = Pools.update_pool(pool, @invalid_attrs)
      assert pool == Pools.get_pool!(pool.id)
    end

    @tag :skip
    test "delete_pool/1 deletes the pool" do
      pool = pool_fixture()
      assert {:ok, %Pool{}} = Pools.delete_pool(pool)
      assert_raise Ecto.NoResultsError, fn -> Pools.get_pool!(pool.id) end
    end

    @tag :skip
    test "change_pool/1 returns a pool changeset" do
      pool = pool_fixture()
      assert %Ecto.Changeset{} = Pools.change_pool(pool)
    end
  end
end
