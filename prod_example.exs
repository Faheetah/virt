Application.put_env(:libvirt, :rpc, backend: Libvirt.RPC.Backends.Direct)

ubuntu_base_url = "http://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"

host =
  case Virt.Libvirt.Hosts.get_host_by_name!("colosseum") do
    nil ->
      Virt.Libvirt.Hosts.create_host(%{name: "colosseum", connection_string: "colosseum.sudov.im"})
      |> then(fn {:ok, host} -> host end)

    host ->
      host
  end

pool =
  case Virt.Libvirt.Pools.get_pool_by_name!("alpha") do
    nil ->
      case Virt.Libvirt.Pools.create_pool(%{name: "alpha", type: "dir", path: "/tmp/pools/alpha", host_id: host.id}) do
        {:ok, pool} -> pool
        _ -> Virt.Libvirt.Pools.get_pool_by_name!("alpha")
      end

    pool ->
      pool
  end

base_image =
  case Virt.Libvirt.Volumes.get_volume_by_name!("UBUNTU20_04") do
    nil ->
      case Virt.Libvirt.Volumes.create_base_image(%{"url" => ubuntu_base_url, "name" => "UBUNTU20_04", "pool_id" => pool.id, "type" => "qcow2"}) do
        {:ok, base_image} -> base_image
        _ -> Virt.Libvirt.Volumes.get_volume_by_name!("UBUNTU20_04")
      end

    base_image ->
      base_image
  end

{:ok, volume} = Virt.Libvirt.Volumes.create_volume(%{name: "guest", type: "qcow2", capacity_bytes: 1024*1024*1024, pool_id: pool.id})
Virt.Libvirt.Domains.create_domain(%{name: "guest", memory_bytes: 256*1024*1024, vcpus: 1, host_id: host.id, domain_disks: [%{"device" => "hda", "volume_id" => volume.id}]})
