terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.46.4" # Utiliza la última versión estable del proveedor
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.13.13:8006/"
  api_token = "juan.larrondo@pve!terraform=82918061-7fd1-4c0b-8da9-24b2d5b542e7"
  insecure  = true # Necesario si el servidor Proxmox utiliza certificados autofirmados
}

resource "proxmox_virtual_environment_vm" "test_backend_01" {
  name        = "test-backend-01"
  node_name   = "proxmoxdev01"
  vm_id       = 500 # ID fuera del rango actual (100-118)

  clone {
    vm_id = 400 # Sustituye por el ID de una plantilla existente en Proxmox
    full = true
  }

  agent {
    enabled = true # Requiere que qemu-guest-agent esté instalado en la plantilla
  }
  
  network_device {
    bridge = "vmbr1" # Sustituir por el nombre real de tu puente de red
  }

  # Bloque de configuración de Cloud-Init
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp" # Cambiar a formato "192.168.X.Y/24" si requieres IP estática
      }
    }
    user_account {
      username = "admin"
      password = "admin" # Contraseña configurada a fuego
    }
  }
}
