defmodule VirtWeb.JobLive.JobComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Provision.Jobs

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Virt.PubSub, "jobs")
    end

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    job = Jobs.get_job!(id)

    {
      :noreply,
      socket
      |> assign(:job, job)
    }
  end
end
