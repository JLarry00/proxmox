module "vms_from_image" {
  source = "../modules/vm-from-image"

  proxmox_node       = var.proxmox_node
  vms                = var.vms_from_image
  vm_id_base         = var.vm_id_base
  gateway            = var.gateway
  dns_servers        = var.dns_servers
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

  proxmox_node       = var.proxmox_node
  vms                = var.vms_from_clone
  template_vm_id     = var.template_vm_id
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

module "vms_from_download" {
  source = "../modules/vm-from-download"

  proxmox_node       = var.proxmox_node
  vms                = var.vms_from_download
  vm_id_base         = var.vm_id_base + length(var.vms_from_image) + length(var.vms_from_clone)
  gateway            = var.gateway
  agent_enabled      = var.agent_enabled
  agent_timeout      = var.agent_timeout
  disk_datastore_id  = var.disk_datastore_id
  files_datastore_id = var.files_datastore_id
  disk_interface     = var.disk_interface
  network_bridge     = var.network_bridge
  vm_username        = var.vm_username
  vm_password        = var.vm_password
}
