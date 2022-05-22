defmodule Virt.Jobs.CreateDomain do
  require Logger

  def init(domain) do
    domain
  end

  def run(job) do
    Virt.Libvirt.Domains.provision_domain(job.attrs.domain)
    |> Virt.Libvirt.Domains.broadcast(:domain_provisioned)
  end

  def cleanup(%{attrs: %{domain: domain}}) do
    Logger.info("Deleting domain #{domain.id}")
    Virt.Libvirt.Domains.delete_domain(domain)
  end
  def cleanup(_) do
    Logger.info("Nothing to clean up for domain")
  end
end
