defmodule VirtWeb.DashboardLive.Index do
  use VirtWeb, :live_view

  alias Virt.Libvirt.Hosts
  alias Virt.Libvirt.Domains
  alias Virt.Provision

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "jobs")
    end

    {
      :ok,
      socket
      |> assign(:hosts, list_hosts())
      |> assign(:domains, list_domains())
      |> assign(:jobs, list_jobs())
    }
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

  @impl true
  def handle_info({:job_deleted, _}, socket) do
    {:noreply, assign(socket, jobs: list_jobs())}
  end

  @impl true
  def handle_info({:job_updated, job}, socket) do
    {:noreply, update(socket, :jobs, fn jobs -> [job | jobs] end)}
  end

  @impl true
  def handle_info({:job_completed, job}, socket) do
    {
      :noreply,
      socket
      |> put_flash(:info, "Job #{job.id} finished successfully")
      |> assign(jobs: list_jobs())
    }
  end

  @impl true
  def handle_info({:job_created, job}, socket) do
    {:noreply, update(socket, :jobs, fn jobs -> [job | jobs] end)}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
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
