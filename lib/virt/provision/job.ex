defmodule Virt.Provision.Job do
  @moduledoc """
  A record of a Virt.Provision.Job that has the current provisioning status
  """

  use Ecto.Schema
  import Ecto.Changeset

  @valid_statuses [
    "ready",
    "running",
    "error",
    "failed",
    "done"
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "jobs" do
    field :pid, :string
    field :module, :string
    field :status, :string
    field :reason, :string
    field :attrs, :map, virtual: true
    field :state, :binary
    timestamps()
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:status, :reason, :module, :attrs, :state, :pid])
    |> validate_inclusion(:status, @valid_statuses)
  end
end
