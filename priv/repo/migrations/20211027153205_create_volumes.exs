defmodule Virt.Repo.Migrations.CreateVolumes do
  use Ecto.Migration

  def change do
    create table(:volumes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :key, :string
      add :type, :string, default: "raw"
      add :capacity_bytes, :integer, null: false
      add :created, :boolean, default: false
      add :pool_id, references(:pools, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:volumes, [:pool_id])
  end
end
