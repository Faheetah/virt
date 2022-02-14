defmodule VirtWeb.DashboardLive.Index do
  use VirtWeb, :live_view

  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Domains

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:hosts, list_hosts())
    |> assign(:domains, list_domains())
    |> then(& {:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Dashboard")
    |> assign(:dashboard, nil)
  end

  defp list_hosts() do
    Hosts.list_hosts()
  end

  defp list_domains() do
    Domains.list_domains()
  end
end
