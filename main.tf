# VMs
resource "proxmox_virtual_environment_vm" "backend_node" {
  count     = length(var.ip_addresses)
  name      = "${var.existing_image_file}-${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = var.vm_id + count.index

  bios = var.bios

  agent {
    enabled = var.agent_enabled
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"    # Usar el tipo host para estabilizar VirtualBox
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.disk_datastore_id
    file_id      = "local:iso/${var.existing_image_file}.img"
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = "raw"
  }

  boot_order = [var.disk_interface, "ide2"]

  network_device {
    bridge = var.network_bridge
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6+
  }

  # En el recurso de la VM, dentro de initialization:
  initialization {
    datastore_id      = var.disk_datastore_id
    interface         = "ide2"
    user_data_file_id = proxmox_virtual_environment_file.user_data[count.index].id

    ip_config {
      ipv4 {
        address = var.ip_addresses[count.index]
        gateway = var.gateway
      }
    }
  }
}

# =======================================================================================

# Recurso para subir el archivo de configuración
resource "proxmox_virtual_environment_file" "user_data" {
  count        = length(var.ip_addresses)
  content_type = "snippets"
  datastore_id = var.files_datastore_id # Datastore donde se almacenarán los archivos.
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/user-data.tftpl", {
      vm_name     = "${var.vm_name}-${count.index + 1}"
      vm_username = var.vm_username
      vm_password = var.vm_password
    })
    file_name = "user-data-${var.vm_name}-${count.index + 1}.yaml"
  }
}