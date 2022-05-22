defmodule VirtWeb.HostLive.PoolFormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  require Logger
  alias Virt.Libvirt.Pools
  alias Virt.Libvirt.Pools.Pool

  @impl true
  def update(%{host: host} = assigns, socket) do
    changeset = Pools.change_pool(%Pool{})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:host, host)
    }
  end

  def handle_params(%{"id" => id}, _, socket) do
    pool =
      Pools.get_pool!(id)

    {
      :noreply,
      socket
      |> assign(:page_title, "New Pool")
      |> assign(:pool, pool)
    }
  end

  @impl true
  def handle_event("validate", %{"pool" => pool_params}, socket) do
    changeset =
      # socket.assigns.pool
      %Pool{}
      |> Pools.change_pool(pool_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"pool" => pool_params}, socket) do
    save_pool(socket, socket.assigns.action, pool_params)
  end

  defp save_pool(socket, :new_pool, pool_params) do
    case Pools.create_pool(pool_params) do
      {:ok, _pool} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pool request processed")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, error} ->
        {:noreply,
          socket
          |> put_flash(:error, "Pool failed to provision: #{error}")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
