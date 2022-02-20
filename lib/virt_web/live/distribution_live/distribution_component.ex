defmodule VirtWeb.DistributionLive.DistributionComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Distributions

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    distribution =
      Distributions.get_distribution!(id)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:distribution, distribution)
    }
  end

  defp page_title(:show), do: "Show Distribution"
  defp page_title(:edit), do: "Edit Distribution"
end
