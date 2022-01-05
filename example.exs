## Setup the host

# {:ok, host} = Virt.Libvirt.Hosts.create_host(%{"name" => Libvirt.UUID.gen_string(), "connection_string" => "localhost"})

Virt.Libvirt.Hosts.create_host(%{"name" => "colosseum.sudov.im", "connection_string" => "colosseum.sudov.im"})
host = Virt.Libvirt.Hosts.get_host_by_name!("colosseum.sudov.im")

## Delete everything

Virt.Libvirt.Domains.list_domains()
|> Enum.each(&Virt.Libvirt.Domains.delete_domain/1)

Virt.Libvirt.Volumes.list_volumes()
|> Enum.each(&Virt.Libvirt.Volumes.delete_volume/1)

Virt.Libvirt.Pools.list_pools()
|> Enum.each(&Virt.Libvirt.Pools.delete_pool/1)

## Create pool

{_, pool} = Virt.Libvirt.Pools.create_pool(%{name: "customer_images", path: "/tmp/pool", type: "dir", host_id: host.id})

## Create base image

{:ok, base_image} =
  %{
    "url" => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img",
    "name" => "UBUNTU_20.04",
    "pool_id" => pool.id
  }
  |> Virt.Libvirt.Volumes.create_base_image()

## Create domain

{:ok, volume} = Virt.Libvirt.Volumes.create_volume(%{type: "qcow2", capacity_bytes: 50*1024*1024*1024, pool_id: pool.id}, "UBUNTU_20.04")
{:ok, second} = Virt.Libvirt.Volumes.create_volume(%{type: "qcow2", capacity_bytes: 100*1024*1024*1024, pool_id: pool.id})
domain_disks = [
  %{device: "hda", volume_id: volume.id},
  %{device: "hdb", volume_id: second.id}
]
{:ok, domain} = Virt.Libvirt.Domains.create_domain(%{name: "test-domain", memory_bytes: 256*1024*1024, vcpus: 1, host_id: host.id, domain_disks: domain_disks})
