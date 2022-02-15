defmodule VirtWeb.DomainLiveTest do
  use VirtWeb.ConnCase

  import Phoenix.LiveViewTest
  import Virt.Libvirt.DomainsFixtures

  @create_attrs %{created: true, memory_bytes: 42, name: "some name", vcpus: 42}
  @update_attrs %{created: false, memory_bytes: 43, name: "some updated name", vcpus: 43}
  @invalid_attrs %{created: false, memory_bytes: nil, name: nil, vcpus: nil}

  defp create_domain(_) do
    domain = domain_fixture()
    %{domain: domain}
  end

  describe "Index" do
    setup [:create_domain]

    @tag :skip
    test "lists all domains", %{conn: conn, domain: domain} do
      {:ok, _index_live, html} = live(conn, Routes.domain_index_path(conn, :index))

      assert html =~ "Listing Domains"
      assert html =~ domain.name
    end

    @tag :skip
    test "saves new domain", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.domain_index_path(conn, :index))

      assert index_live |> element("a", "New Domain") |> render_click() =~
               "New Domain"

      assert_patch(index_live, Routes.domain_index_path(conn, :new))

      assert index_live
             |> form("#domain-form", domain: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#domain-form", domain: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.domain_index_path(conn, :index))

      assert html =~ "Domain created successfully"
      assert html =~ "some name"
    end

    @tag :skip
    test "updates domain in listing", %{conn: conn, domain: domain} do
      {:ok, index_live, _html} = live(conn, Routes.domain_index_path(conn, :index))

      assert index_live |> element("#domain-#{domain.id} a", "Edit") |> render_click() =~
               "Edit Domain"

      assert_patch(index_live, Routes.domain_index_path(conn, :edit, domain))

      assert index_live
             |> form("#domain-form", domain: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#domain-form", domain: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.domain_index_path(conn, :index))

      assert html =~ "Domain updated successfully"
      assert html =~ "some updated name"
    end

    @tag :skip
    test "deletes domain in listing", %{conn: conn, domain: domain} do
      {:ok, index_live, _html} = live(conn, Routes.domain_index_path(conn, :index))

      assert index_live |> element("#domain-#{domain.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#domain-#{domain.id}")
    end
  end

  describe "Show" do
    setup [:create_domain]

    @tag :skip
    test "displays domain", %{conn: conn, domain: domain} do
      {:ok, _show_live, html} = live(conn, Routes.domain_show_path(conn, :show, domain))

      assert html =~ "Show Domain"
      assert html =~ domain.name
    end

    @tag :skip
    test "updates domain within modal", %{conn: conn, domain: domain} do
      {:ok, show_live, _html} = live(conn, Routes.domain_show_path(conn, :show, domain))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Domain"

      assert_patch(show_live, Routes.domain_show_path(conn, :edit, domain))

      assert show_live
             |> form("#domain-form", domain: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#domain-form", domain: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.domain_show_path(conn, :show, domain))

      assert html =~ "Domain updated successfully"
      assert html =~ "some updated name"
    end
  end
end
