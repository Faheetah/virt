defmodule Virt.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :path, :string, null: false
      add :autostart, :boolean, default: true
      add :host_id, references(:hosts, on_delete: :delete_all, type: :binary_id)
      add :status, :string, default: "PROVISIONING"

      timestamps()
    end

    create(unique_index(:pools, [:host_id, :name]))
    create(unique_index(:pools, [:host_id, :path]))
  end
end
