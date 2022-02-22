defmodule VirtWeb.SubnetLive.FormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Network.Subnets

  @impl true
  def update(%{subnet: subnet} = assigns, socket) do
    changeset = Subnets.change_subnet(subnet)
    subnets = Subnets.list_subnets()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:subnets, subnets)
    }
  end

  @impl true
  def handle_event("validate", %{"subnet" => subnet_params}, socket) do
    changeset =
      socket.assigns.subnet
      |> Subnets.change_subnet(subnet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"subnet" => subnet_params}, socket) do
    save_subnet(socket, socket.assigns.action, subnet_params)
  end

  defp save_subnet(socket, :new, subnet_params) do
    case Subnets.create_subnet(subnet_params) do
      {:ok, _subnet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subnet request processed")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, "Subnet failed to provision")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
