# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Virt.Repo.insert!(%Virt.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# [
#   %{
#     "name" => "Ubuntu 20.04",
#     "key" => "UBUNTU_20_04",
#     "source" => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
#   },
#   %{
#     "name" => "Ubuntu 22.04",
#     "key" => "UBUNTU_22_04",
#     "source" => "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
#   },
#   %{
#     "name" => "CentOS 7.11",
#     "key" => "CENTOS_7_11",
#     "source" => "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1711.qcow2c"
#   }
# ]
# |> Enum.each(&Virt.Libvirt.Distributions.create_distribution/1)
