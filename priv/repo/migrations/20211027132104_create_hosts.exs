defmodule Virt.Repo.Migrations.CreateHosts do
  use Ecto.Migration

  def change do
    create table(:hosts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :connection_string, :string, null: false
      add :status, :string, null: false

      timestamps()
    end

    create(unique_index(:hosts, [:name, :connection_string]))
  end
end
