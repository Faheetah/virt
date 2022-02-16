defmodule VirtWeb.DomainLive.FormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Libvirt.Domains

  @impl true
  def update(%{domain: domain} = assigns, socket) do
    changeset = Domains.change_domain(domain)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"domain" => domain_params}, socket) do
    changeset =
      socket.assigns.domain
      |> Domains.change_domain(domain_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"domain" => domain_params}, socket) do
    save_domain(socket, socket.assigns.action, domain_params)
  end

  defp save_domain(socket, :new, domain_params) do
    case Domains.create_domain(domain_params) do
      {:ok, _domain} ->
        {:noreply,
         socket
         |> put_flash(:info, "Domain request processed")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, "Domain failed to provision")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
