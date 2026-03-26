# main_local_image.tf

#############################
# Terraform Configuration   #
#############################
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox" # Proveedor externo para Proxmox VE disponible en el Registry de Terraform.
      version = "0.46.4"      # Especificar la versión asegura compatibilidad y reproducibilidad.
    }
  }
}

##############################
# Configuración del provider #
##############################

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true # Deshabilita validación de certificados SSL. No recomendado en producción.
}

###########################################################
# Recurso: Creación de la VM desde una imagen existente   #
###########################################################
resource "proxmox_virtual_environment_vm" "backend_node" {
  count     = length(var.ip_addresses)
  name      = "${var.vm_name}-${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = var.vm_id + count.index

  agent {
    enabled = var.agent_enabled
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.disk_datastore_id
    file_id      = var.existing_image_file
    interface    = "virtio0"
    size         = var.disk_size
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    # --- Aprovisionamiento Personalizado (Desactivado por ahora) ---
    # Descomentar la siguiente línea para inyectar configuraciones avanzadas 
    # (ej. instalación de Jenkins/Java) definidas en cloud_init.tf y user-data.tftpl.
    # Al estar comentada, la VM arranca limpia, aplicando solo IP y credenciales básicas.
    # user_data_file_id = proxmox_virtual_environment_file.user_data.id

    # Configuración de los servidores DNS
    dns {
      servers = var.dns_servers
    }

    # Configuración de la red
    ip_config {
      ipv4 {
        address = var.ip_addresses[count.index]
        gateway = var.gateway
      }
    }

    # Configuración de acceso
    user_account {
      username = var.vm_username
      password = var.vm_password
    }
  }
}


output "vm_ipv4_addresses" {
  description = "Direcciones IP asignadas a las máquinas virtuales por DHCP"
  value       = [for vm in proxmox_virtual_environment_vm.backend_node : vm.ipv4_addresses]
}