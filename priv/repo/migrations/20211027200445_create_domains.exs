defmodule Virt.Repo.Migrations.CreateDomains do
  use Ecto.Migration

  def change do
    create table(:domains, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :host_id, :integer
      add :memory_bytes, :integer, null: false
      add :vcpus, :integer, null: false
      add :created, :boolean, default: false
      add :host_id, references(:hosts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:domains, [:host_id])
  end
end
