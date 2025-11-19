defmodule Virt.Secrets.AccessKeys.AccessKey do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "access_keys" do
    field :name, :string
    field :comment, :string
    field :public_key, :string
    # belongs_to :user not implemented

    timestamps()
  end

  @doc false
  def changeset(access_key, attrs) do
    access_key
    |> cast(attrs, [:name, :public_key])
    |> validate_required([:name, :public_key])
    |> parse_key(attrs)
  end

  def parse_key(changeset, attrs) do
    public_key = String.trim(attrs["public_key"] || "")

    try do
      # need to try multiple key types
      [{{_, _, _}, [comment: comment]}] = :ssh_file.decode(public_key, :public_key)
      changeset
      |> Ecto.Changeset.put_change(:public_key, public_key)
      |> Ecto.Changeset.put_change(:comment, List.to_string(comment))
    rescue
      MatchError -> Ecto.Changeset.add_error(changeset, :public_key, "could not parse public key", public_key: attrs["public_key"])
    end
  end
end
