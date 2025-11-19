## Setup the host

Virt.Libvirt.Hosts.create_host!(%{"name" => "localhost", "connection_string" => "localhost", "status" => "ONLINE"})
Virt.Libvirt.Hosts.get_host_by_name!("localhost")
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

%{"name" => "test", "public_key" => "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0PGj4CgahDYEQVQKHC/YIds0dgqXUCexqq2WjmSng9 testcomment"}
|> Virt.Secrets.AccessKeys.create_access_key()
|> IO.inspect

%{"label" => "test", "subnet" => "192.0.2.0/24"}
|> Virt.Network.Subnets.create_subnet()
|> IO.inspect

IO.puts "done"
