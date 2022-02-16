defmodule Virt.Repo.Migrations.AddJobs do
  use Ecto.Migration

  def change do
    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pid, :string
      add :module, :string
      add :status, :string
      add :reason, :string
      add :state, :binary

      timestamps()
    end
  end
end
