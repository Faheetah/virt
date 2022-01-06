defmodule VirtWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `VirtWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal VirtWeb.HostLive.FormComponent,
        id: @host.id || :new,
        action: @live_action,
        host: @host,
        return_to: Routes.host_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(VirtWeb.ModalComponent, modal_opts)
  end
end
