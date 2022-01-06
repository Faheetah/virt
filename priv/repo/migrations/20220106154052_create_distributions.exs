defmodule Virt.Repo.Migrations.CreateDistributions do
  use Ecto.Migration

  def change do
    create table(:distributions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :key, :string
      add :source, :string

      timestamps()
    end

    create(unique_index(:distributions, [:key]))
  end
end
