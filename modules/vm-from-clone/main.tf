resource "proxmox_virtual_environment_vm" "vm" {
  for_each  = var.vms

  name      = each.key
  node_name = var.proxmox_node
  vm_id     = var.vm_id_base + index(keys(var.vms), each.key)

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = var.agent_enabled
    timeout = var.agent_timeout
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id      = var.disk_datastore_id
    interface         = "ide2"
    user_data_file_id = proxmox_virtual_environment_file.user_data[each.key].id

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_file" "user_data" {
  for_each     = var.vms
  content_type = "snippets"
  datastore_id = var.files_datastore_id
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/user-data.tftpl", {
      vm_name     = each.key
      vm_username = var.vm_username
      vm_password = var.vm_password
    })
    file_name = "user-data-${each.key}.yaml"
  }
}
