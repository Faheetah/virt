import Config

config :libvirt, :rpc, backend: Libvirt.RPC.Backends.Direct

config :virt,
  ecto_repos: [Virt.Repo],
  generators: [binary_id: true]

config :virt, VirtWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: VirtWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Virt.PubSub,
  live_view: [signing_salt: "bvQqF1ej"]

config :virt, Virt.Mailer, adapter: Swoosh.Adapters.Local

config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
