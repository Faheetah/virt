defmodule VirtWeb.CloudInitController do
  use VirtWeb, :controller

  action_fallback VirtWeb.FallbackController

  def userdata(conn, %{"id" => id}) do
    userdata =
      Virt.Libvirt.Domains.get_domain!(id)
      |> Virt.Repo.preload([domain_interfaces: [ip_address: [:subnet]]])
      |> Virt.CloudInit.Userdata.create_userdata()
    text(conn, userdata)
  end

  def metadata(conn, _params) do
    # data = %{id: "id", name: "name", interfaces: [%{device: "eth0", ip_address: "192", subnet: %{network: "255", netmask: "255", broadcast: "255", gateway: "1"}}]}
    # metadata = Virt.CloudInit.Metadata.create_metadata(data)
    # text(conn, metadata)
    text(conn, "")
  end

  def vendordata(conn, _params) do
    text(conn, "")
  end
end
