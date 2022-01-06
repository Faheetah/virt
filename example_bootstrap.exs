## Setup the host

Virt.Libvirt.Hosts.create_host(%{"name" => "colosseum.sudov.im", "connection_string" => "colosseum.sudov.im"})
host = Virt.Libvirt.Hosts.get_host_by_name!("colosseum.sudov.im")

Virt.Libvirt.Pools.create_pool(%{name: "base_images", path: "/tmp/pool/base", type: "dir", host_id: host.id})
Virt.Libvirt.Pools.create_pool(%{name: "customer_images", path: "/tmp/pool/cuastomer", type: "dir", host_id: host.id})

{:ok, distribution} =
  Virt.Libvirt.Distributions.create_distribution(%{
    "source" => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img",
    "key" => "UBUNTU_20.04",
    "name" => "Ubuntu 20.04"
  })

Virt.Libvirt.Distributions.synchronize_distribution(distribution)
|> Task.await_many(:infinity)

IO.puts "done"
