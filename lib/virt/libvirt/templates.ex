defmodule Virt.Libvirt.Templates do
  require EEx
  EEx.function_from_file(:def, :render_pool, "lib/virt/libvirt/templates/pool.eex", [:pool])
  EEx.function_from_file(:def, :render_volume, "lib/virt/libvirt/templates/volume.eex", [:volume])
end
