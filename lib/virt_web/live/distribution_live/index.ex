defmodule VirtWeb.DistributionLive.Index do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Libvirt.Distributions
  alias Virt.Libvirt.Distributions.Distribution

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "distributions")
    end

    {:ok, assign(socket, :distributions, list_distributions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    distribution = Distributions.get_distribution!(id)

    socket
    |> assign(:page_title, "Edit #{distribution.name}")
    |> assign(:distribution, distribution)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Distribution")
    |> assign(:distribution, %Distribution{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:distribution, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    distribution = Distributions.get_distribution!(id)
    {:ok, _} = Distributions.delete_distribution(distribution)

    {:noreply, assign(socket, :distributions, list_distributions())}
  end

  def handle_event("synchronize", %{"id" => id}, socket) do
    distribution = Distributions.get_distribution!(id)
    Virt.Libvirt.Distributions.synchronize_distribution(distribution)

    {:noreply, assign(socket, :distributions, list_distributions())}
  end

  @impl true
  def handle_info({:distribution_synchronized, distribution}, socket) do
    {:noreply, put_flash(socket, :info, "Distribution #{distribution.key} synchronized")}
  end

  def handle_info({:distribution_synchronize_failed, distribution}, socket) do
    {:noreply, put_flash(socket, :error, "Distribution #{distribution.key} failed to synchronize")}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp list_distributions do
    Distributions.list_distributions()
  end
end
