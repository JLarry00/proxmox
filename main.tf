# VMs
resource "proxmox_virtual_environment_vm" "backend_node" {
  started = false
  on_boot = false

  count     = length(var.ip_addresses)
  name      = "${var.existing_image_file}-${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = var.vm_id + count.index

  bios = var.bios
  # efi_disk {
  #   datastore_id = var.disk_datastore_id
  #   file_format  = "raw"
  #   type         = "4m"
  # }

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

  # initialization {
  #   # --- Aprovisionamiento Personalizado (Desactivado por ahora) ---
  #   # Descomentar la siguiente línea para inyectar configuraciones avanzadas 
  #   # (ej. instalación de Jenkins/Java) definidas en cloud_init.tf y user-data.tftpl.
  #   # Al estar comentada, la VM arranca limpia, aplicando solo IP y credenciales básicas.
  #   # user_data_file_id = proxmox_virtual_environment_file.user_data.id

  #   datastore_id = var.disk_datastore_id

  #   dns {
  #     servers = var.dns_servers
  #   }

  #   ip_config {
  #     ipv4 {
  #       address = var.ip_addresses[count.index]
  #       gateway = var.gateway
  #     }
  #   }

  #   user_account {
  #     username = var.vm_username
  #     password = var.vm_password
  #     keys     = []  # ← permite login por contraseña
  #   }
  # }
}

# =======================================================================================

# Recurso para subir el archivo de configuración
resource "proxmox_virtual_environment_file" "user_data" {
  count        = length(var.ip_addresses)
  content_type = "snippets"
  datastore_id = var.files_datastore_id # Datastore donde se almacenarán los archivos.
  node_name    = var.proxmox_node

  source_raw {
    data = <<EOF
#cloud-config
hostname: ${var.vm_name}-${count.index + 1}
users:
  - name: ${var.vm_username}
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    passwd: ${bcrypt(var.vm_password)}
ssh_pwauth: true
EOF
    file_name = "user-data-${var.vm_name}-${count.index + 1}.yaml"
  }
}