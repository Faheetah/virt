defmodule VirtWeb.CloudInitController do
  use VirtWeb, :controller

  action_fallback VirtWeb.FallbackController

  def metadata(conn, _params) do

    data = %{id: "id", name: "name", interfaces: [%{device: "eth0", ip_address: "192", subnet: %{network: "255", netmask: "255", broadcast: "255", gateway: "1"}}]}
    metadata = Virt.CloudInit.Metadata.create_metadata(data)
    render(conn, "metadata.json", metadata: metadata)
  end
end
