defmodule Virt.Libvirt.DomainsTest do
  use Virt.DataCase

  alias Virt.Libvirt.Domains

  describe "domains" do
    alias Virt.Libvirt.Domains.Domain

    import Virt.Libvirt.DomainsFixtures

    @invalid_attrs %{memory_bytes: nil, name: nil, vcpus: nil}

    test "list_domains/0 returns all domains" do
      domain = domain_fixture()
      assert Domains.list_domains() == [domain]
    end

    test "get_domain!/1 returns the domain with given id" do
      domain = domain_fixture()
      assert Domains.get_domain!(domain.id) == domain
    end

    test "create_domain/1 with valid data creates a domain" do
      valid_attrs = %{memory_bytes: 42, name: "some name", vcpus: 42}

      assert {:ok, %Domain{} = domain} = Domains.create_domain(valid_attrs)
      assert domain.memory_bytes == 42
      assert domain.name == "some name"
      assert domain.vcpus == 42
    end

    test "create_domain/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Domains.create_domain(@invalid_attrs)
    end

    test "update_domain/2 with valid data updates the domain" do
      domain = domain_fixture()
      update_attrs = %{memory_bytes: 43, name: "some updated name", vcpus: 43}

      assert {:ok, %Domain{} = domain} = Domains.update_domain(domain, update_attrs)
      assert domain.memory_bytes == 43
      assert domain.name == "some updated name"
      assert domain.vcpus == 43
    end

    test "update_domain/2 with invalid data returns error changeset" do
      domain = domain_fixture()
      assert {:error, %Ecto.Changeset{}} = Domains.update_domain(domain, @invalid_attrs)
      assert domain == Domains.get_domain!(domain.id)
    end

    test "delete_domain/1 deletes the domain" do
      domain = domain_fixture()
      assert {:ok, %Domain{}} = Domains.delete_domain(domain)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_domain!(domain.id) end
    end

    test "change_domain/1 returns a domain changeset" do
      domain = domain_fixture()
      assert %Ecto.Changeset{} = Domains.change_domain(domain)
    end
  end
end
