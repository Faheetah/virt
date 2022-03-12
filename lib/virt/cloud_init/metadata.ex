defmodule Virt.CloudInit.Metadata do
  @moduledoc false

  @doc """
  instance-id: iid-abcdefg
  network-interfaces: |
    iface eth0 inet static
    address 192.168.1.10
    network 192.168.1.0
    netmask 255.255.255.0
    broadcast 192.168.1.255
    gateway 192.168.1.254
  hostname: myhost
  """
  def create_metadata(domain) do
    %{
      "instance-id" => domain.id,
      "hostname" => domain.name,
      "network-interfaces" => generate_network_interfaces(domain.interfaces)
    }
    |> Jason.encode!()
  end

  def generate_network_interfaces([]), do: nil
  def generate_network_interfaces(interfaces) do
      Enum.map(interfaces, fn interface ->
        """
        iface #{interface.device} inet static
        address #{interface.ip_address}
        network #{interface.subnet.network}
        netmask #{interface.subnet.netmask}
        broadcast #{interface.subnet.broadcast}
        gateway #{interface.subnet.gateway}
        """
      end)
      |> Enum.join("\n")
  end
end
