resource "proxmox_virtual_environment_vm" "template" {
  for_each = var.templates

  name        = each.key
  node_name   = var.proxmox_node
  vm_id       = each.value.vm_id
  description = each.value.description
  template    = true
  started     = false

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = local.downloaded_image_ids[each.value.image_key]
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }
}
