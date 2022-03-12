defmodule Virt.Repo.Migrations.CreateDomainAccessKeys do
  use Ecto.Migration

  def change do
    create table(:domain_access_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :access_key_id, references(:access_keys, type: :binary_id, on_delete: :nilify_all)
      add :domain_id, references(:domains, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:domain_access_keys, [:domain_id])
    create index(:domain_access_keys, [:access_key_id])
    create(unique_index(:domain_access_keys, [:domain_id, :access_key_id]))
  end
end
