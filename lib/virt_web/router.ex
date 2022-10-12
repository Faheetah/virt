defmodule VirtWeb.Router do
  use VirtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {VirtWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VirtWeb do
    pipe_through :browser

    get "/ci/:id/meta-data", CloudInitController, :metadata
    get "/ci/:id/user-data", CloudInitController, :userdata
    get "/ci/:id/vendor-data", CloudInitController, :vendordata
    get "/ci/:id/provisioned", CloudInitController, :provisioned

    live "/", DashboardLive.Index, :index
    live "/job/:id", DashboardLive.Index, :show

    live "/hosts", HostLive.Index, :index
    live "/hosts/new", HostLive.Index, :new
    live "/hosts/:id/edit", HostLive.Index, :edit

    live "/hosts/:id", HostLive.Show, :show
    live "/hosts/:id/pools/new", HostLive.Show, :new_pool
    live "/hosts/:id/show/edit", HostLive.Show, :edit

    live "/distributions", DistributionLive.Index, :index
    live "/distributions/new", DistributionLive.Index, :new
    live "/distributions/:id/edit", DistributionLive.Index, :edit

    live "/subnets", SubnetLive.Index, :index
    live "/subnets/new", SubnetLive.Index, :new
    live "/subnets/:id/edit", SubnetLive.Index, :edit
    live "/subnets/:id", SubnetLive.Show, :show

    live "/access_keys", AccessKeyLive.Index, :index
    live "/access_keys/new", AccessKeyLive.Index, :new
    live "/access_keys/:id/edit", AccessKeyLive.Index, :edit

    live "/domains", DomainLive.Index, :index
    live "/domains/new", DomainLive.Index, :new
    live "/domains/:id/edit", DomainLive.Index, :edit
    live "/domains/:id", DomainLive.Show, :show
    live "/domains/:id/show/edit", DomainLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", VirtWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: VirtWeb.Telemetry
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
