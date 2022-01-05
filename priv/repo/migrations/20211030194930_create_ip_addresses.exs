defmodule Virt.Repo.Migrations.CreateIpAddresses do
  use Ecto.Migration

  def change do
    create table(:ip_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :address, :bigint
      add :subnet_id, references(:subnets, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:ip_addresses, [:subnet_id])
  end
end
