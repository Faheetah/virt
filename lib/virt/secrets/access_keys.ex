defmodule Virt.Secrets.AccessKeys do
  import Ecto.Query, warn: false
  alias Virt.Repo

  alias Virt.Secrets.AccessKeys.AccessKey

  def list_access_keys do
    Repo.all(AccessKey)
  end

  def get_access_key!(id), do: Repo.get!(AccessKey, id)

  def create_access_key(attrs \\ %{}) do
    AccessKey.changeset(%AccessKey{}, attrs)
    |> Repo.insert()
  end

  def update_access_key(%AccessKey{} = access_key, attrs) do
    AccessKey.changeset(access_key, attrs)
    |> Repo.update()
  end

  def delete_access_key(%AccessKey{} = access_key) do
    Repo.delete(access_key)
  end

  def change_access_key(%AccessKey{} = access_key, attrs \\ %{}) do
    AccessKey.changeset(access_key, attrs)
  end
end
