defmodule Virt.Repo.Migrations.CreateSubnets do
  use Ecto.Migration

  def change do
    create table(:subnets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :network, :bigint
      add :gateway, :bigint
      add :broadcast, :bigint
      add :netmask, :bigint

      timestamps()
    end
  end
end
