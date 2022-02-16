defmodule Virt.Jobs.CreateDomain do
  require Logger

  def init(attrs) do
    {:ok, domain} = Virt.Libvirt.Domains.reserve_domain(attrs)
    %{domain: domain}
  end

  def run(job) do
    :timer.sleep(2000)
    Virt.Libvirt.Domains.provision_domain(job.attrs.domain)
    |> Virt.Libvirt.Domains.broadcast(:domain_provisioned)
  end

  def cleanup(job) do
    Logger.info("Deleting domain #{job.attrs.domain.id}")
    Virt.Libvirt.Domains.delete_domain(job.attrs.domain)
  end
end
