defmodule VirtWeb.HostLiveTest do
  use VirtWeb.ConnCase

  import Phoenix.LiveViewTest
  import Virt.Libvirt.HostsFixtures

  @create_attrs %{connection_string: "some connection_string", name: "some name"}
  @update_attrs %{connection_string: "some updated connection_string", name: "some updated name"}
  @invalid_attrs %{connection_string: nil, name: nil}

  defp create_host(_) do
    host = host_fixture()
    %{host: host}
  end

  describe "Index" do
    setup [:create_host]

    @tag :skip
    test "lists all hosts", %{conn: conn, host: host} do
      {:ok, _index_live, html} = live(conn, Routes.host_index_path(conn, :index))

      assert html =~ "Listing Hosts"
      assert html =~ host.connection_string
    end

    @tag :skip
    test "saves new host", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.host_index_path(conn, :index))

      assert index_live |> element("a", "New Host") |> render_click() =~
               "New Host"

      assert_patch(index_live, Routes.host_index_path(conn, :new))

      assert index_live
             |> form("#host-form", host: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#host-form", host: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.host_index_path(conn, :index))

      assert html =~ "Host created successfully"
      assert html =~ "some connection_string"
    end

    @tag :skip
    test "updates host in listing", %{conn: conn, host: host} do
      {:ok, index_live, _html} = live(conn, Routes.host_index_path(conn, :index))

      assert index_live |> element("#host-#{host.id} a", "Edit") |> render_click() =~
               "Edit Host"

      assert_patch(index_live, Routes.host_index_path(conn, :edit, host))

      assert index_live
             |> form("#host-form", host: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#host-form", host: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.host_index_path(conn, :index))

      assert html =~ "Host updated successfully"
      assert html =~ "some updated connection_string"
    end

    @tag :skip
    test "deletes host in listing", %{conn: conn, host: host} do
      {:ok, index_live, _html} = live(conn, Routes.host_index_path(conn, :index))

      assert index_live |> element("#host-#{host.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#host-#{host.id}")
    end
  end

  describe "Show" do
    setup [:create_host]

    @tag :skip
    test "displays host", %{conn: conn, host: host} do
      {:ok, _show_live, html} = live(conn, Routes.host_show_path(conn, :show, host))

      assert html =~ "Show Host"
      assert html =~ host.connection_string
    end

    @tag :skip
    test "updates host within modal", %{conn: conn, host: host} do
      {:ok, show_live, _html} = live(conn, Routes.host_show_path(conn, :show, host))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Host"

      assert_patch(show_live, Routes.host_show_path(conn, :edit, host))

      assert show_live
             |> form("#host-form", host: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#host-form", host: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.host_show_path(conn, :show, host))

      assert html =~ "Host updated successfully"
      assert html =~ "some updated connection_string"
    end
  end
end
