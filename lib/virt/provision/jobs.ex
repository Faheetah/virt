defmodule Virt.Provision.Jobs do
  import Ecto.Query, warn: false
  require Logger

  alias Virt.Provision.Job
  alias Virt.Repo

  def list_jobs() do
    Repo.all(Job)
  end

  def list_running_jobs() do
    Repo.all(from j in Job, where: j.status in ["ready", "running"])
  end

  def list_failed_jobs() do
    Repo.all(from j in Job, where: j.status in ["error", "failed"])
  end

  def get_job!(id) do
    Repo.get!(Job, id)
  end

  def create_job(module, attrs) do
    %Job{}
    |> Job.changeset(%{"status" => "ready", "module" => Atom.to_string(module), "attrs" => attrs, "state" => :erlang.term_to_binary(attrs)})
    |> Repo.insert()
  end

  def update_job_status(job, status) do
    job
    |> Job.changeset(%{"status" => status})
    |> Repo.update()
  end

  def assign_pid(job, pid) do
    job
    |> Job.changeset(%{"pid" => List.to_string(:erlang.pid_to_list(pid))})
    |> Repo.update()
  end

  def fail_job(job, reason) do
    job
    |> Job.changeset(%{"status" => "failed", "reason" => reason})
    |> Repo.update()
  end

  def delete_job(domain) do
    Repo.delete(domain)
  end

  def delete_all() do
    Repo.delete_all(Job)
  end
end
