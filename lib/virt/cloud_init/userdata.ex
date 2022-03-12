defmodule Virt.CloudInit.Userdata do
  @moduledoc false

  def create_userdata(domain) do
    "#cloud-config\n" <> Jason.encode!(
    %{
      hostname: domain.name,
      users: [
        %{
          name: "main",
          shell: "/bin/bash",
          sudo: "ALL=(ALL) NOPASSWD:ALL",
          lock_passwd: false,
          hashed_passwd: "$6$rounds=4096$wR/HnZAa$5Ob0hvdk7Pqscdaxs5VZky9U5OZdgkwkraTfvAhHL2BhT9fJ2bvxIRz/vpi7fASweK4RoepjCioYycKzfNawP1",
          ssh_authorized_keys: Enum.map(domain.domain_access_keys, fn key -> key.access_key.public_key end)
        }
      ],
      write_files: [
        %{
          path: "/etc/netplan/50-cloud-init.yaml",
          permissions: "0400",
          content: Jason.encode!(%{
            network: %{
              version: 2,
              ethernets: get_ethernets(domain)
            }
          })
        },
        %{
          path: "/etc/guest-id",
          permissions: "0400",
          content: domain.id
        }
      ],
      runcmd: [
        ["netplan", "apply"],
        # retries as network comes up
        "for i in 1 2 3 4 5; do curl http://169.254.169.254/ci/#{domain.id}/provisioned && break || sleep 1; done"
      ]
    }
    )
  end

  def get_ethernets(domain) do
    domain.domain_interfaces
    |> Enum.reject(fn interface -> interface.ip_address == nil end)
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {interface, index}, acc ->
      Map.put(acc, "eth#{index}", %{
        "match" => %{macaddress: interface.mac},
        "dhcp4" => false,
        "addresses" => [
          "#{interface.ip_address.address}/#{Virt.Network.Subnets.calculate_cidr(interface.ip_address.subnet.netmask)}"
        ],
        "gateway4" => interface.ip_address.subnet.gateway,
        "nameservers" => %{"addresses" => ["8.8.8.8", "8.8.4.4"]},
        "set-name" => "eth#{index}"
      })
    end)
  end

  def calculate_gateway!(ip) do
    [addr, mask] = String.split(ip, "/")
    {mask_bits, _} = Integer.parse(mask)
    {:ok, parsed_addr} = Virt.Ecto.Type.IPv4.dump(addr)
    gateway = 4_294_967_296 - Integer.pow(2, 32 - mask_bits)
    Virt.Ecto.Type.IPv4.load(Bitwise.band(gateway, parsed_addr) + 1)
    |> then(fn {:ok, f} -> f end)
  end
end
