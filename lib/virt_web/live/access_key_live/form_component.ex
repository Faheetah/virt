defmodule VirtWeb.AccessKeyLive.FormComponent do
  @moduledoc false

  use VirtWeb, :live_component

  alias Virt.Secrets.AccessKeys

  @impl true
  def update(%{access_key: access_key} = assigns, socket) do
    changeset = AccessKeys.change_access_key(access_key)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"access_key" => access_key_params}, socket) do
    changeset =
      socket.assigns.access_key
      |> AccessKeys.change_access_key(access_key_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"access_key" => access_key_params}, socket) do
    save_access_key(socket, socket.assigns.action, access_key_params)
  end

  defp save_access_key(socket, :new, access_key_params) do
    case AccessKeys.create_access_key(access_key_params) do
      {:ok, _access_key} ->
        {:noreply,
         socket
         |> put_flash(:info, "AccessKey request processed")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, "AccessKey failed to provision")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
