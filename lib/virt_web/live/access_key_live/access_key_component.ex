defmodule VirtWeb.AccessKeyLive.AccessKeyComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.AccessKeys

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    access_key =
      AccessKeys.get_access_key!(id)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:access_key, access_key)
    }
  end

  defp page_title(:show), do: "Show AccessKey"
  defp page_title(:edit), do: "Edit AccessKey"
end
