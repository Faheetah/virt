defmodule VirtWeb.AccessKeyLive.Index do
  @moduledoc false

  use VirtWeb, :live_view

  alias Virt.Secrets.AccessKeys
  alias Virt.Secrets.AccessKeys.AccessKey

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "access_keys")
    end

    {:ok, assign(socket, :access_keys, list_access_keys())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    access_key = AccessKeys.get_access_key!(id)
    socket
    |> assign(:page_title, "Edit #{access_key.name}")
    |> assign(:access_key, access_key)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New AccessKey")
    |> assign(:access_key, %AccessKey{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:access_key, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    access_key = AccessKeys.get_access_key!(id)
    {:ok, _} = AccessKeys.delete_access_key(access_key)

    {:noreply, assign(socket, :access_keys, list_access_keys())}
  end

  @impl true
  def handle_info({:access_key_deleted, access_key}, socket) do
    {
      :noreply,
      socket
      |> clear_flash()
      |> put_flash(:error, "AccessKey #{access_key.id} deleted")
      |> assign(access_keys: list_access_keys())
    }
  end

  @impl true
  def handle_info({:access_key_provisioned, _access_key}, socket) do
    {:noreply, assign(socket, :access_keys, list_access_keys())}
  end

  defp list_access_keys do
    AccessKeys.list_access_keys()
  end
end
