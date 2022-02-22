defmodule VirtWeb.SubnetLive.Index do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Network.Subnets
  alias Virt.Network.Subnets.Subnet

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "subnets")
    end

    {:ok, assign(socket, :subnets, list_subnets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    subnet = Subnets.get_subnet!(id)

    socket
    |> assign(:page_title, "Edit #{subnet.name}")
    |> assign(:subnet, subnet)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subnet")
    |> assign(:subnet, %Subnet{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:subnet, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subnet = Subnets.get_subnet!(id)
    {:ok, _} = Subnets.delete_subnet(subnet)

    {:noreply, assign(socket, :subnets, list_subnets())}
  end

  def handle_event("synchronize", %{"id" => id}, socket) do
    subnet = Subnets.get_subnet!(id)
    Virt.Network.Subnets.synchronize_subnet(subnet)

    {:noreply, assign(socket, :subnets, list_subnets())}
  end

  @impl true
  def handle_info({:subnet_synchronized, subnet}, socket) do
    {:noreply, put_flash(socket, :info, "Subnet #{subnet.key} synchronized")}
  end

  def handle_info({:subnet_synchronize_failed, subnet}, socket) do
    {:noreply, put_flash(socket, :error, "subnet #{subnet.key} failed to synchronize")}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp list_subnets do
    Subnets.list_subnets()
  end
end
