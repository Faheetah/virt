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
  |> Enum.each(&Libvirt.storage_vol_delete(host, %{"vol" => &1}))

  Libvirt.storage_pool_destroy(host, %{"pool" => pool})
  Libvirt.storage_pool_undefine(host, %{"pool" => pool})
end)
