defmodule VirtWeb.DashboardLive.JobDetailComponent do
  @moduledoc false

  use VirtWeb, :live_component

  def format_state(state) do
    state
    |> :erlang.binary_to_term
    |> inspect(pretty: true)
    |> String.split("\n")
  end
end
