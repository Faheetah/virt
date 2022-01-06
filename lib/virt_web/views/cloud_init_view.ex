defmodule VirtWeb.CloudInitView do
  use VirtWeb, :view
  alias VirtWeb.CloudInitView

  def render("metadata.txt", %{metadata: metadata}) do
    metadata
  end

  def render("userdata.json", %{userdata: userdata}) do
    userdata
  end
end
