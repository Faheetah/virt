defmodule Virt.Provision do
  # Provisioning module to run jobs

  require Logger

  alias Virt.Provision.Jobs

  # List all active jobs
  # might be good to add a filter to this
  def list_running_jobs() do
    Jobs.list_running_jobs()
  end

  def list_failed_jobs() do
    Jobs.list_failed_jobs()
  end

  def delete_job(id) do
    Jobs.get_job!(id)
    |> Jobs.delete_job()
  end

  def restart_job(_job) do
    # include resuming state erlang:binary_to_term to attrs
  end

  # start a new provision with the provided attributes
  def run_job(job_module, attrs) do
    {:ok, job} = Jobs.create_job(job_module, job_module.init(attrs))
    Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_created, job})

    {:ok, pid} = Task.Supervisor.start_child(Virt.TaskSupervisor, fn ->
      Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_updated, job})
      # no matter the result of the job run, we need to report the status
      try do
        {:ok, job} = Jobs.update_job_status(job, "running")
        Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_updated, job})
        Logger.info "Starting job #{job.id} #{job.module}"
        job_module.run(job)
        Logger.info("Finished #{job.id} #{job.module}")
        {:ok, job} = Jobs.update_job_status(job, "done")
        Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_competed, job})
      rescue
        exception ->
          fail_job(job_module, job, exception)
          reraise exception, __STACKTRACE__
      catch
        reason -> fail_job(job_module, job, reason)
      end
    end)

    Jobs.assign_pid(job, pid)

    {:ok, job}
  end

  defp fail_job(job_module, job, reason) do
    try do
      job_module.cleanup(job)
    rescue
      exception ->
        {:ok, _} = Jobs.update_job_status(job, "error")
        Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_deleted, job})
        Logger.error("Job could not clean up #{job.id}: #{Exception.message(reason)}")
        reraise exception, __STACKTRACE__
    catch
      reason ->
        {:ok, _} = Jobs.update_job_status(job, "error")
        Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_deleted, job})
        Logger.error("Job could not clean up #{job.id}: #{Exception.message(reason)}\n#{Exception.format_stacktrace()}")
    after
      {:ok, _} = Jobs.fail_job(job, reason)
      Phoenix.PubSub.broadcast(Virt.PubSub, "jobs", {:job_deleted, job})
      Logger.warn("Job failed with reason: #{inspect reason}")
    end
  end
end
