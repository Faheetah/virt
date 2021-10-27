defmodule Virt.Libvirt.Templates do
  @moduledoc """
  Generate templates for various Libvirt XML resources
  """

  require EEx
  EEx.function_from_file(:def, :render_pool, "lib/virt/libvirt/templates/pool.eex", [:pool])
  EEx.function_from_file(:def, :render_volume, "lib/virt/libvirt/templates/volume.eex", [:volume])
  EEx.function_from_file(:def, :render_domain, "lib/virt/libvirt/templates/domain.eex", [:domain])
end
