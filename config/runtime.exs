import Config

if config_env() == :prod do
  config :virt, Virt.Repo,
    pool_size: 10,
    url: System.get_env("DATABASE_URL") || raise "DATABASE_URL not set"

  config :virt, VirtWeb.Endpoint,
    url: [host: System.get_env("URL") || "localhost", port: 4000],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: 4000],
    secret_key_base: System.get_env("SECRET_KEY_BASE") || raise "SECRET_KEY_BASE not set"

  config :virt, VirtWeb.Endpoint, server: true
end
