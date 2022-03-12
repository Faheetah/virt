defmodule VirtWeb.CloudInitController do
  use VirtWeb, :controller

  action_fallback VirtWeb.FallbackController

  def userdata(conn, %{"id" => id}) do
    userdata =
      Virt.Libvirt.Domains.get_domain!(id)
      |> Virt.Repo.preload([domain_interfaces: [ip_address: [:subnet]], domain_access_keys: [:access_key]])
      |> Virt.CloudInit.Userdata.create_userdata()
    text(conn, userdata)
  end

  def metadata(conn, _params) do
    text(conn, "")
  end

  def vendordata(conn, _params) do
    text(conn, "")
  end

  def provisioned(conn, %{"id" => id}) do
    {:ok, domain} =
      Virt.Libvirt.Domains.get_domain!(id)
      |> Virt.Libvirt.Domains.update_domain(%{created: true, online: true})

    Phoenix.PubSub.broadcast(Virt.PubSub, "domains", {:domain_provisioned, domain})
    text(conn, "OK")
  end
end
