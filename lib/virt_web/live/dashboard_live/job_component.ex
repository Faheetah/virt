defmodule VirtWeb.JobLive.JobComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Provision.Jobs

  def job_color("ready"), do: "bg-grey-100"
  def job_color("running"), do: "bg-yellow-100"
  def job_color("error"), do: "bg-red-100"
  def job_color("failed"), do: "bg-red-100"
  def job_color("done"), do: "bg-green-100"
  def job_color(_), do: "bg-grey-100"
end
