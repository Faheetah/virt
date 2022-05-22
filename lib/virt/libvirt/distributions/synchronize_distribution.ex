defmodule Virt.Jobs.SynchronizeDistribution do
  require Logger

  alias Virt.Libvirt.{Volumes,Distributions,Hosts}

  def init(distribution) do
    %{distribution: distribution}
  end

  def run(job) do
    distribution = job.attrs.distribution
    {:ok, _} = Volumes.download_image(distribution.source, distribution.key)

    Hosts.list_hosts
    |> Enum.map(&Distributions.start_transfer(&1, distribution))
    |> Enum.reject(fn t -> t == nil end)
    |> Task.await_many(600_000)

    Phoenix.PubSub.broadcast(Virt.PubSub, "distributions", {:distribution_synchronized, distribution})
  end

  def cleanup(job) do
    Phoenix.PubSub.broadcast(Virt.PubSub, "distributions", {:distribution_synchronize_failed, job.attrs.distribution})
  end
end
