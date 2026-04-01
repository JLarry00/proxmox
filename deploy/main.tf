locals {
  # Sustituye el image_id corto de cada VM por el file_id completo de Proxmox,
  # resolviendo desde el catálogo unificado (static_images + images/ descargadas).
  vms_from_image_resolved = {
    for k, v in var.vms_from_image : k => merge(v, {
      image_id = local.all_image_ids[v.image_id]
    })
  }
}

module "vms_from_image" {
  source = "../modules/vm-from-image"

  proxmox_node       = var.proxmox_node
  vms                = local.vms_from_image_resolved
  vm_id_base         = var.vm_id_base
  gateway            = var.gateway
  bios               = var.bios
  agent_enabled      = var.agent_enabled
  agent_timeout      = var.agent_timeout
  disk_datastore_id  = var.disk_datastore_id
  files_datastore_id = var.files_datastore_id
  disk_interface     = var.disk_interface
  network_bridge     = var.network_bridge
  vm_username        = var.vm_username
  vm_password        = var.vm_password
}

module "vms_from_clone" {
  source = "../modules/vm-from-clone"

  proxmox_node = var.proxmox_node
  vms          = var.vms_from_clone
  # Resuelve el nombre corto de la plantilla a su VM ID numérico.
  # try() devuelve 0 si vms_from_clone está vacío y template_name no está definido.
  template_vm_id     = try(local.all_template_ids[var.template_name], 0)
  vm_id_base         = var.vm_id_base + length(var.vms_from_image)
  gateway            = var.gateway
  agent_enabled      = var.agent_enabled
  agent_timeout      = var.agent_timeout
  disk_datastore_id  = var.disk_datastore_id
  files_datastore_id = var.files_datastore_id
  network_bridge     = var.network_bridge
  vm_username        = var.vm_username
  vm_password        = var.vm_password
}
