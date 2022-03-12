defmodule Virt.Repo.Migrations.CreateAccessKeys do
  use Ecto.Migration

  def change do
    create table(:access_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :public_key, :text
      add :comment, :string

      timestamps()
    end
  end
end
