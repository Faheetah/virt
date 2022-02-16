defmodule Virt.Provision.Jobs.Test do
  require Logger

  # statuses: :ready, :running, :error, :done
  def init(attrs) do
    attrs
  end

  def run(job) do
    :timer.sleep(1000 * job.attrs.i)
    Logger.info "processing i: #{inspect job.attrs.i}"
    if rem(job.attrs.i, 3) == 0 do
      throw "BAD got #{job.attrs.i}"
    end
  end

  def cleanup(job) do
    Logger.info "Cleaning up job #{job.id}"
  end
end
