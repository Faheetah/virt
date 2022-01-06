## Get host and pool

host = Virt.Libvirt.Hosts.get_host_by_name!("colosseum.sudov.im")
pool = Virt.Libvirt.Pools.get_pool_by_name!(host.id, "customer_images")

# abstract this
import Ecto.Query
distribution = Virt.Libvirt.Distributions.get_distribution_by_key!("UBUNTU_20.04")
ubuntu = Virt.Repo.one(from hd in Virt.Libvirt.Hosts.HostDistribution, where: [host_id: ^host.id, distribution_id: ^distribution.id]) |> Virt.Repo.preload([:volume])
base_image = Virt.Repo.preload(ubuntu.volume, [:pool])

## Create domain

{:ok, volume} = Virt.Libvirt.Volumes.create_volume(%{type: "qcow2", capacity_bytes: 50*1024*1024*1024, pool_id: pool.id}, base_image)
{:ok, second} = Virt.Libvirt.Volumes.create_volume(%{type: "qcow2", capacity_bytes: 100*1024*1024*1024, pool_id: pool.id})
domain_disks = [
  %{device: "hda", volume_id: volume.id},
  %{device: "hdb", volume_id: second.id}
]

domain_interfaces = [
  %{type: "user", mac: "16:92:54:00:00:01", ip: "169.254.0.1/24"},
  %{type: "bridge", mac: "1c:ed:de:ad:b0:0b", bridge: "br0", ip: "10.0.0.50/24"}
]

{:ok, _domain} = Virt.Libvirt.Domains.create_domain(%{name: "test-domain", memory_bytes: 256*1024*1024, vcpus: 1, host_id: host.id, domain_disks: domain_disks, domain_interfaces: domain_interfaces})
