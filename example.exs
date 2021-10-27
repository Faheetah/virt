{:ok, host} = Virt.Libvirt.Hosts.create_host(%{"name" => Libvirt.UUID.gen_string(), "connection_string" => "localhost"})
IO.inspect host

{:ok, socket} = Libvirt.connect(host.connection_string)

pool_name = Libvirt.UUID.gen_string()
{:ok, pool} = Virt.Libvirt.Pools.create_pool(%{name: pool_name, path: "/tmp/#{pool_name}", type: "dir", host_id: host.id})
IO.inspect pool

volume_name = Libvirt.UUID.gen_string()
{:ok, volume} = Virt.Libvirt.Volumes.create_volume(%{name: volume_name, capacity_bytes: 1024*1024, pool_id: pool.id})
IO.inspect volume

domain_name = Libvirt.UUID.gen_string()
{:ok, domain} = Virt.Libvirt.Domains.create_domain(%{name: domain_name, memory_bytes: 256*1024*1024, vcpus: 1, host_id: host.id})
IO.inspect domain
IO.inspect Libvirt.connect_list_all_domains(socket, %{"need_results" => 1, "flags" => 0})

Virt.Libvirt.Domains.delete_domain(domain)
IO.inspect Libvirt.connect_list_all_domains(socket, %{"need_results" => 1, "flags" => 0})

Virt.Libvirt.Volumes.delete_volume(volume)
IO.inspect Libvirt.storage_pool_list_all_volumes(socket, %{"pool" => %{"name" => pool.name, "uuid" => pool.id}, "need_results" => 1, "flags" => 0})

Virt.Libvirt.Pools.delete_pool(pool)
IO.inspect Libvirt.connect_list_all_storage_pools(socket, %{"need_results" => 1, "flags" => 0})
