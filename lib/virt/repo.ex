defmodule Virt.Repo do
  use Ecto.Repo,
    otp_app: :virt,
    adapter: Ecto.Adapters.Postgres
end
