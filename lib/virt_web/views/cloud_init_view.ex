defmodule VirtWeb.CloudInitView do
  use VirtWeb, :view
  alias VirtWeb.CloudInitView

  def render("metadata.json", %{metadata: metadata}) do
    metadata
  end
end
