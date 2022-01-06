defmodule Virt.Repo.Migrations.CreateHostDistribution do
  use Ecto.Migration

  def change do
    create table(:host_distribution, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :host_id, references(:hosts, on_delete: :nothing, type: :binary_id)
      add :distribution_id, references(:distributions, on_delete: :nothing, type: :binary_id)
      add :volume_id, references(:volumes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:host_distribution, [:host_id])
    create index(:host_distribution, [:distribution_id])
    create index(:host_distribution, [:volume_id])
    create unique_index(:host_distribution, [:host_id, :distribution_id])
  end
end
