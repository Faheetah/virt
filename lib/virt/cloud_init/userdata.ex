defmodule Virt.CloudInit.Userdata do
  @moduledoc false

  def create_userdata(domain) do
    domain.userdata || "#cloud-config\n"
    # Virt.CloudInit.Vendordata.create_vendordata(domain)
  end
end
