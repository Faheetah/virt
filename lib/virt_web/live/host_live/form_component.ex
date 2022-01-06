defmodule VirtWeb.HostLive.FormComponent do
  use VirtWeb, :live_component

  alias Virt.Libvirt.Hosts

  @impl true
  def update(%{host: host} = assigns, socket) do
    changeset = Hosts.change_host(host)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"host" => host_params}, socket) do
    changeset =
      socket.assigns.host
      |> Hosts.change_host(host_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"host" => host_params}, socket) do
    save_host(socket, socket.assigns.action, host_params)
  end

  defp save_host(socket, :edit, host_params) do
    case Hosts.update_host(socket.assigns.host, host_params) do
      {:ok, _host} ->
        {:noreply,
         socket
         |> put_flash(:info, "Host updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_host(socket, :new, host_params) do
    case Hosts.create_host(host_params) do
      {:ok, _host} ->
        {:noreply,
         socket
         |> put_flash(:info, "Host created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
