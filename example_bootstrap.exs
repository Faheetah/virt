## Setup the host

Virt.Libvirt.Hosts.create_host(%{"name" => "colosseum.sudov.im", "connection_string" => "colosseum.sudov.im", "status" => "ONLINE"})
host = Virt.Libvirt.Hosts.get_host_by_name!("colosseum.sudov.im")

Virt.Libvirt.Pools.create_pool(%{name: "base_images", path: "/tmp/pool/base", type: "dir", host_id: host.id})
|> IO.inspect
Virt.Libvirt.Pools.create_pool(%{name: "customer_images", path: "/tmp/pool/customer", type: "dir", host_id: host.id})
|> IO.inspect

create_distribution =
  Virt.Libvirt.Distributions.create_distribution(%{
    "source" => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img",
    "key" => "UBUNTU_20.04",
    "name" => "Ubuntu 20.04"
  })

case create_distribution do
  {:ok, distribution} -> distribution
  {:error, _} -> Virt.Libvirt.Distributions.get_distribution_by_key!("UBUNTU_20.04")
end
|> Virt.Libvirt.Distributions.synchronize_distribution()
|> Task.await_many(:infinity)

IO.puts "done"
