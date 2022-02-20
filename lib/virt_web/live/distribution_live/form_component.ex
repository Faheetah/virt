defmodule VirtWeb.DistributionLive.FormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Distributions

  @impl true
  def update(%{distribution: distribution} = assigns, socket) do
    changeset = Distributions.change_distribution(distribution)
    distributions = Distributions.list_distributions()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:distributions, distributions)
    }
  end

  @impl true
  def handle_event("validate", %{"distribution" => distribution_params}, socket) do
    changeset =
      socket.assigns.distribution
      |> Distributions.change_distribution(distribution_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"distribution" => distribution_params}, socket) do
    save_distribution(socket, socket.assigns.action, distribution_params)
  end

  defp save_distribution(socket, :new, distribution_params) do
    case Distributions.create_distribution(distribution_params) do
      {:ok, _distribution} ->
        {:noreply,
         socket
         |> put_flash(:info, "Distribution request processed")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, "Distribution failed to provision")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
