defmodule VirtWeb.DashboardLive.Index do
  use VirtWeb, :live_view

  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Domains
  alias Virt.Provision

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:hosts, list_hosts())
    |> assign(:domains, list_domains())
    |> assign(:jobs, list_jobs())
    |> then(& {:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = Provision.delete_job(id)

    {:noreply, assign(socket, :domains, list_domains())}
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

  defp list_jobs() do
    Provision.list_running_jobs() ++ Provision.list_failed_jobs()
  end
end
