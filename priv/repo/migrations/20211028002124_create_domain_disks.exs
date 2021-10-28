defmodule Virt.Repo.Migrations.CreateDomainDisks do
  use Ecto.Migration

  def change do
    create table(:domain_disks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :device, :string, null: false
      add :domain_id, references(:domains, on_delete: :delete_all, type: :binary_id)
      add :volume_id, references(:volumes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:domain_disks, [:domain_id])
    create index(:domain_disks, [:volume_id])
  end
end
