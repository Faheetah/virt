defmodule Virt.Repo.Migrations.CreateDomainInterfaces do
  use Ecto.Migration

  def change do
    create table(:domain_interfaces, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :mac, :string, null: false
      add :bridge, :string
      add :ip_address_id, references(:ip_addresses, type: :binary_id, on_delete: :delete_all)
      add :domain_id, references(:domains, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:domain_interfaces, [:domain_id])
    create(unique_index(:domain_interfaces, [:mac]))
  end
end
