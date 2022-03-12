defmodule Virt.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pid, :string
      add :module, :string
      add :status, :string
      add :reason, :text
      add :state, :binary

      timestamps()
    end
  end
end
