# Deletes everything from the given host, do this to clean up
# Works even if the db has been reset

{:ok, host} = Libvirt.connect("colosseum.sudov.im")

args = %{"need_results" => 1, "flags" => 0}

Libvirt.connect_list_all_domains(host, args)
|> then(&elem(&1, 1))
|> Map.get("domains")
|> IO.inspect(label: :domains)
|> Enum.each(&Libvirt.domain_destroy(host, %{"dom" => &1}))

Libvirt.connect_list_all_storage_pools(host, args)
|> then(&elem(&1, 1))
|> Map.get("pools")
|> IO.inspect(label: :pools)
|> Enum.each(fn pool ->
  Libvirt.storage_pool_list_all_volumes(host, Map.put(args, "pool", pool))
  |> then(&elem(&1, 1))
  |> Map.get("vols")
  |> IO.inspect(label: :pool)
  |> Enum.each(&Libvirt.storage_vol_delete(host, %{"vol" => &1, "flags" => 0}))

  Libvirt.storage_pool_destroy(host, %{"pool" => pool})
  Libvirt.storage_pool_undefine(host, %{"pool" => pool})
end)

## Setup the host

Virt.Libvirt.Hosts.create_host(%{"name" => "colosseum.sudov.im", "connection_string" => "colosseum.sudov.im", "status" => "ONLINE"})
host = Virt.Libvirt.Hosts.get_host_by_name!("colosseum.sudov.im")

Virt.Libvirt.Pools.create_pool(%{name: "base_images", path: "/tmp/pool/base", type: "dir", host_id: host.id})
Virt.Libvirt.Pools.create_pool(%{name: "customer_images", path: "/tmp/pool/customer", type: "dir", host_id: host.id})

{:ok, distribution} = Virt.Libvirt.Distributions.get_distribution_by_key!("UBUNTU_20.04")

Virt.Libvirt.Distributions.synchronize_distribution(distribution)
|> Task.await_many(:infinity)

IO.puts "done"
